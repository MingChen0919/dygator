#' \code{create_shed_yml} creates a \code{.shed.yml} file within the elagator directory.
#'
#' @param name a string used as ToolShed repository name.
#' @param owner ToolShed user account.
#' @param description a brief introduction to the tool.
#' @param long_description  detailed information about this tool.
#' @param type tool type. Default is 'unrestricted'
#' @param categories a vector of strings to specify which categories this tool belongs to.
#' @export
create_shed_yml = function(name, owner, description, long_description="", type='unrestricted', categories='') {
  l = list()
  l$name = name
  l$owner = owner
  l$description = description
  l$long_description = long_description
  l$type = type
  l$categories = categories
  write_yaml(l, 'elagator/.shed.yml')
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

  if (!file.exists('elagator/.shed.yml')) {
    stop('elagator/.shed.yml file does not exist. Please add a valid .shed.yml
         file to your elagator directory first.')
  }

  # create tool repository first
  command_1 = paste0('cd elagator && planemo shed_create --shed_target ', toolshed)
  system(command = command_1)
  command_2 = paste0('cd elagator && planemo shed_update --check_diff --shed_target ', toolshed)
  system(command = command_2)
}
