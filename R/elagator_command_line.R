#' @keywords internal
"_PACKAGE"

#' @import xml2
#' @import dplyr
#' @import yaml
#' @importFrom magrittr %>%
NULL

#' \code{init_elagator_command_line} initialize a elastic galay tool repository
#'
#' @export
init_elagator_command_line = function() {
  if (dir.exists('elagator_command_line')) {
    stop('You already have an initialized elastic galaxy tool repository! You can run reinit_elagator() to
         re-initiate a new repository.')
  }
  elagator_template_dir = system.file('extdata', package = 'elagator_command_line')
  from_files = list.files(elagator_template_dir, pattern = 'elastic_tool*', full.names = TRUE)
  to_files = paste0('elagator_command_line/', unlist(lapply(strsplit(from_files, '/'), tail, 1)))
  dir.create('elagator_command_line')
  if (all(file.copy(from_files, to_files, overwrite = TRUE))) {
    cat('elagator_command_line is successfully initialized.\n')
  } else {
    cat('initialization failed.\n')
  }
}

#' \code{reinit_elagator_command_line} overwrite the existing elastic galaxy tool repository with a new one.
#'
#' @export
reinit_elagator_command_line = function() {
  if (dir.exists('elagator_command_line')) {
    unlink('elagator', recursive = TRUE)
  }
  if (!all(init_elagator()) ) {
    cat('re-initialization failed.\n')
  }
}



#' \code{add_requirements_command_line} add tool requirement to the galaxy tool xml file.
#'
#' @param packages a string vector of packages that can be found in the anaconda repository.
#' @param versions a string vector of corresponding package versions.
#' @export
add_requirements_command_line = function(packages, versions) {
  if (!dir.exists('elagator_command_line')) {
    stop('elagator does not exist. Please run init_elagator() to initialize a tool first.')
  }

  macros_xml_content = read_xml('elagator_command_line/elastic_tool_wrappers_macros.xml')

  for (i in 1:length(packages)) {
    exist_packages = xml_find_all(macros_xml_content, 'xml/requirement') %>% xml_text()
    if (!packages[i] %in% exist_packages) {
      # add a new requirement
      macros_xml_content %>%
        xml_find_all('xml/requirement') %>%
        tail(1) %>%
        xml_add_sibling('requirement', packages[i],
                        type = 'package', version = versions[i])
    }
  }

  # update elastic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_command_line/elastic_tool_wrappers_macros.xml')
}

#' \code{remove_requirements_command_line} remove existing requirements
#'
#' @param requirements a vector of package names.
#' @export
remove_requirements_command_line = function(requirements) {
  if (!file.exists('elagator_command_line/elastic_tool_wrappers_macros.xml')) {
    stop('elagator_command_line/elastic_tool_wrappers_macros.xml does not exist. Please make sure you have a elagator directory
         in your working directory')
  }
  macros_xml_content = read_xml('elagator_command_line/elastic_tool_wrappers_macros.xml')

  exist_packages = xml_find_all(macros_xml_content, 'xml/requirement') %>% xml_text()
  xml_remove(xml_find_all(macros_xml_content, 'xml/requirement')[which(exist_packages %in% requirements)])
  # update elastic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_command_line/elastic_tool_wrappers_macros.xml')
}


#' \code{add_tools_command_line} add tools to 'elagator/elastic_tool_wrappers_macros.xml'.
#'
#' @param tools a string vector of tool names.
#' @export
add_tools_command_line = function(tools) {
  if (!dir.exists('elagator')) {
    stop('elagator does not exist. Please run init_elagator() to initialize a tool first.')
  }

  macros_xml_content = read_xml('elagator_command_line/elastic_tool_wrappers_macros.xml')

  exist_tools = xml_find_all(macros_xml_content, 'xml/param') %>% xml_text()
  for (i in tools) {
    if (!i %in% exist_tools) {
      # add a new requirement
      macros_xml_content %>%
        xml_find_all('xml/param') %>%
        tail(1) %>%
        xml_add_child('option', i,
                        value = i, selected = 'false')
    }
  }

  # update elastic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_command_line/elastic_tool_wrappers_macros.xml')
}


#' \code{remove_tools} remove tools from 'elagator/elastic_tool_wrappers_macros.xml'.
#' @param tools a string vector of tool names.
#' @export
remove_tools_command_line = function(tools) {
  if (!file.exists('elagator_command_line/elastic_tool_wrappers_macros.xml')) {
    stop('elagator_command_line/elastic_tool_wrappers_macros.xml does not exist. Please make sure you have a elagator directory
         in your working directory')
  }
  macros_xml_content = read_xml('elagator_command_line/elastic_tool_wrappers_macros.xml')

  exist_tools = xml_find_all(macros_xml_content, 'xml/param/option') %>% xml_text()
  xml_remove(xml_find_all(macros_xml_content, 'xml/param/option')[which(exist_tools %in% tools)])
  # update elastic_tool_wrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_command_line/elastic_tool_wrappers_macros.xml')
}


#' \code{it_tool} specify id, name, and version for your tool.
#' @param id a string used for tool id. Default is 'tool_id'.
#' @param name a string used for tool name. Default is 'tool name'
#' @param version a string used for tool version. Defualt is '1.0.0'
#' @export
id_tool_command_line = function(id='tool_id', name='tool name', version='1.0.0') {
  if (!file.exists('elagator_command_line/elastic_tool.xml')) {
    stop('elagator_command_line/elastic_tool.xml does not exist. Please make sure you have a elagator directory
         in your working directory')
  }

  xml_content = read_xml('elagator_command_line/elastic_tool.xml')
  xml_attrs(xml_content) = c(id=id, name=name, version=version)
  # update elastic_tool.xml
  write_xml(xml_content, file = 'elagator_command_line/elastic_tool.xml')
}





