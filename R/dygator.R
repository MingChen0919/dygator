#' @keywords internal
"_PACKAGE"

#' @import xml2
#' @import dplyr
#' @importFrom magrittr %>%
NULL

#' \code{init_dygator} initialize a dynamic galay tool repository
#'
#' @export
init_dygator = function() {
  if (dir.exists('dygator')) {
    stop('You already have an initialized dynamic galaxy tool repository! You can run reinit_dygator() to
         re-initiate a new repository.')
  }
  dygator_template_dir = system.file('extdata', package = 'dygator')
  from_files = list.files(dygator_template_dir, pattern = 'dynamic_*', full.names = TRUE)
  to_files = paste0('dygator/', unlist(lapply(strsplit(from_files, '/'), tail, 1)))
  dir.create('dygator')
  if (all(file.copy(from_files, to_files, overwrite = TRUE))) {
    cat('dygator is successfully initialized.\n')
  } else {
    cat('initialization failed.\n')
  }
}

#' \code{reinit_dygator} overwrite the existing dynamic galaxy tool repository with a new one.
#'
#' @export
reinit_dygator = function() {
  if (dir.exists('dygator')) {
    unlink('dygator', recursive = TRUE)
  }
  if (!all(init_dygator()) ) {
    cat('re-initialization failed.\n')
  }
}



#' \code{add_requirements} add tool requirement to the galaxy tool xml file.
#'
#' @param df a data frame or a matrix with two columns: the first column are package names from anaconda
#' repository; the second column are corresponding package versions.
#' @importFrom magrittr %>%
#' @export
add_requirements = function(df) {
  if (!dir.exists('dygator')) {
    stop('dygator does not exist. Please run init_dygator() to initialize a tool first.')
  }

  macros_xml_content = read_xml('dygator/dynamic_tool_wrappers_macros.xml')

  for (i in 1:nrow(df)) {
    exist_packages = xml_find_all(macros_xml_content, 'xml/requirement') %>% xml_text()
    if (!df[i, 1] %in% exist_packages) {
      # add a new requirement
      macros_xml_content %>%
        xml_find_all('xml/requirement') %>%
        tail(1) %>%
        xml_add_sibling('requirement', df[i, 1],
                        type = 'package', version = df[i, 2])
    }
  }

  # update dynamic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'dygator/dynamic_tool_wrappers_macros.xml')
}

#' \code{remove_requirements} remove existing requirements
#'
#' @param requirements a vector of package names.
#' @export
remove_requirements = function(requirements) {
  if (!file.exists('dygator/dynamic_tool_wrappers_macros.xml')) {
    stop('dygator/dynamic_tool_wrappers_macros.xml does not exist. Please make sure you have a dygator directory
         in your working directory')
  }
  macros_xml_content = read_xml('dygator/dynamic_tool_wrappers_macros.xml')

  exist_packages = xml_find_all(macros_xml_content, 'xml/requirement') %>% xml_text()
  xml_remove(xml_find_all(macros_xml_content, 'xml/requirement')[which(exist_packages %in% requirements)])
  # update dynamic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'dygator/dynamic_tool_wrappers_macros.xml')
}


#' \code{add_tools} add tools to 'dygator/dynamic_tool_wrappers_macros.xml'.
#'
#' @param tools a string vector of tool names.
#' @export
add_tools = function(tools) {
  if (!dir.exists('dygator')) {
    stop('dygator does not exist. Please run init_dygator() to initialize a tool first.')
  }

  macros_xml_content = read_xml('dygator/dynamic_tool_wrappers_macros.xml')

  exist_tools = xml_find_all(macros_xml_content, 'xml/param') %>% xml_text()
  for (i in tools) {
    if (!i %in% exist_tools) {
      # add a new requirement
      macros_xml_content %>%
        xml_find_all('xml/param') %>%
        tail(1) %>%
        xml_add_child('option', i,
                        value = 'package', selected = 'false')
    }
  }

  # update dynamic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'dygator/dynamic_tool_wrappers_macros.xml')
}


#' \code{remove_tools} remove tools from 'dygator/dynamic_tool_wrappers_macros.xml'.
#' @param tools a string vector of tool names.
#' @export
remove_tools = function(tools) {
  if (!file.exists('dygator/dynamic_tool_wrappers_macros.xml')) {
    stop('dygator/dynamic_tool_wrappers_macros.xml does not exist. Please make sure you have a dygator directory
         in your working directory')
  }
  macros_xml_content = read_xml('dygator/dynamic_tool_wrappers_macros.xml')

  exist_tools = xml_find_all(macros_xml_content, 'xml/param/option') %>% xml_text()
  xml_remove(xml_find_all(macros_xml_content, 'xml/param/option')[which(exist_tools %in% tools)])
  # update dynamic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'dygator/dynamic_tool_wrappers_macros.xml')
}


#' \code{it_tool} specify id, name, and version for your tool.
#' @param id a string used for tool id. Default is 'tool_id'.
#' @param name a string used for tool name. Default is 'tool name'
#' @param version a string used for tool version. Defualt is '1.0.0'
#' @export
it_tool = function(id='tool_id', name='tool name', version='1.0.0') {
  if (!file.exists('dygator/dynamic_tool.xml')) {
    stop('dygator/dynamic_tool.xml does not exist. Please make sure you have a dygator directory
         in your working directory')
  }

  xml_content = read_xml('dygator/dynamic_tool.xml')
  xml_attrs(xml_content) = c(id=id, name=name, version=version)
  # update dynamic_tool.xml
  write_xml(xml_content, file = 'dygator/dynamic_tool.xml')
}


#' \code{publish_tool} publish/update tool repository to Galaxy Test ToolShed or ToolShed.
#'
#' @param toolshed a string to indicate which ToolShed to publish to. Valid values include 'testtoolshed' and
#' 'toolshed'.
#' @export
publish_tool = function(toolshed = 'testtoolshed') {
  if (!toolshed %in% c('toolshed', 'testtoolshed')) {
    stop('toolshed value can only be "testtoolshed" or "toolshed"')
  }

  if (!file.exists('dygator/.shed.yml')) {
    stop('dygator/.shed.yml file does not exist. Please add a valid .shed.yml
         file to your dygator directory first.')
  }

  # create tool repository first
  command_1 = paste0('cd dygator && planemo shed_create --shed_target ', toolshed)
  system(command = command_1)
  command_2 = paste0('cd dygator && planemo shed_update --check_diff --shed_target ', toolshed)
  system(command = command_2)
}


