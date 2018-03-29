#' \code{init_elagator_r_package} initialize a elastic galay tool repository
#'
#' @export
init_elagator_r_package = function() {
  if (dir.exists('elagator_r_package')) {
    stop('You already have an initialized elastic galaxy tool repository! You can run reinit_elagator() to
         re-initiate a new repository.')
  }
  elagator_template_dir = system.file('extdata', package = 'elagator_r_package')
  from_files = list.files(elagator_template_dir, pattern = 'elastic_tool*', full.names = TRUE)
  to_files = paste0('elagator_r_package/', unlist(lapply(strsplit(from_files, '/'), tail, 1)))
  dir.create('elagator_r_package')
  if (all(file.copy(from_files, to_files, overwrite = TRUE))) {
    cat('elagator_r_package is successfully initialized.\n')
  } else {
    cat('initialization failed.\n')
  }
  }

#' \code{reinit_elagator_r_package} overwrite the existing elastic galaxy tool repository with a new one.
#'
#' @export
reinit_elagator_r_package = function() {
  if (dir.exists('elagator_r_package')) {
    unlink('elagator', recursive = TRUE)
  }
  if (!all(init_elagator()) ) {
    cat('re-initialization failed.\n')
  }
}


#' \code{add_requirements_r_package} add tool requirement to the galaxy tool xml file.
#'
#' @param packages a string vector of packages that can be found in the anaconda repository.
#' @param versions a string vector of corresponding package versions.
#' @export
add_requirements_r_package = function(packages, versions) {
  if (!dir.exists('elagator_r_package')) {
    stop('elagator does not exist. Please run init_elagator() to initialize a tool first.')
  }

  macros_xml_content = read_xml('elagator_r_package/elastic_r_packagewrappers_macros.xml')

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

  # update elastic_r_packagewrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_r_package/elastic_r_packagewrappers_macros.xml')
}

#' \code{remove_requirements_r_package} remove existing requirements
#'
#' @param requirements a vector of package names.
#' @export
remove_requirements_r_package = function(requirements) {
  if (!file.exists('elagator_r_package/elastic_r_packagewrappers_macros.xml')) {
    stop('elagator_r_package/elastic_r_packagewrappers_macros.xml does not exist. Please make sure you have a elagator directory
         in your working directory')
  }
  macros_xml_content = read_xml('elagator_r_package/elastic_r_packagewrappers_macros.xml')

  exist_packages = xml_find_all(macros_xml_content, 'xml/requirement') %>% xml_text()
  xml_remove(xml_find_all(macros_xml_content, 'xml/requirement')[which(exist_packages %in% requirements)])
  # update elastic_r_packagewrappers_macros.xml
  write_xml(macros_xml_content, file = 'elagator_r_package/elastic_r_packagewrappers_macros.xml')
}


#' \code{add_r_functions}
#'
#' @param function_names a string vector of function names that you want to expose to end users.
#' @export
add_r_functions = function(function_names) {
  r_functions_xml = read_xml('elagator_r_package/elastic_r_functions_macros.xml')
  xml_functions_parent = xml_find_all(r_functions_xml, xpath = 'xml')

  for (fun_name in function_names) {
    r_functions_xml %>%
      xml_find_first('xml') %>%
      xml_add_child('option', fun_name,
                    value= fun_name, selected='false')
  }
  write_xml(r_functions_xml, file = 'elagator_r_package/elastic_r_functions_macros.xml')
}
