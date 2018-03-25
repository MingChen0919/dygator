# Dynamic Galaxy Tool wrappers

Use this repository as a template to develop a elastic Galaxy tools in one minute!

## Step 1: clone this repository

```bash
git clone https://github.com/statonlab/elastic-galaxy-tool-wrappers.git
``` 

## Step 2: edit tool requirements

Open the `elastic_tool_wrappers_macros.xml` file and add your tool requirements. **Only tools from the 
[conda repository](https://anaconda.org/anaconda/repo) can be added as a tool requirement. For example, for a wrapper
of the **FastQC** tool, go to [https://anaconda.org/anaconda/repo](https://anaconda.org/anaconda/repo) and search for
`fastqc`. You will get a list of `fastqc` tools. Find the appropriate version and add it as a tool requirement.

Before editing tool requirement:

```xml
    <xml name="rmarkdown_requirements">
        <requirement type="package" version="1.15.0.6-0">pandoc</requirement>
        <requirement type="package" version="1.6">r-rmarkdown</requirement>
    </xml>
```

After editing tool requirement:

```xml
    <xml name="rmarkdown_requirements">
        <requirement type="package" version="1.15.0.6-0">pandoc</requirement>
        <requirement type="package" version="1.6">r-rmarkdown</requirement>
        <requirement type="package" version="0.11.7">fastqc</requirement>
    </xml>
```



## Step 3: edit template for a specific command line tool

Open the `elastic_tool_wrappers_macros.xml` file and replace `tool_name` in 
`<option value="tool_name" selected="false">tool_name</option>` with a valid command line tool name.

```xml
    <xml name="tool_name">
        <param type="select" name="tool_name" multiple="false" label="Tool name">
            <option value="tool_name" selected="false">tool_name</option>
        </param>
    </xml>
```

Use the **FastQC** tool as an example again, the content after replacement would be

```xml
    <xml name="tool_name">
        <param type="select" name="tool_name" multiple="false" label="Tool name">
            <option value="fastqc" selected="false">fastqc</option>
        </param>
    </xml>
```

You can add multiple `tool_name` options if the tool has sub command line tools. For example, 
for the `samtools` tool, it could be

```xml
    <xml name="tool_name">
        <param type="select" name="tool_name" multiple="false" label="Tool name">
            <option value="samtools view" selected="false">samtols view</option>
            <option value="samtools sort" selected="false">samtols sort</option>
            <option value="samtools index" selected="false">samtols index</option>
        </param>
    </xml>
```

## Step 4: edit **tool name** and **tool id** in `elastic_tool.xml`

Open the `elastic_tool.xml` file and replace `elastic_tool` with an appropriate **tool id** and the `elastic tool` with
an appropriate **tool name**.

```xml
<tool id="elastic_tool" name="elastic tool" version="1.0.0">
```

Use the **FastQC** tool as an example, it could be:

```xml
<tool id="elastic_fastqc" name="Dynamic FastQC" version="1.0.0">
```

## Step 5: Publish tool to [ToolShed](https://toolshed.g2.bx.psu.edu/) or [Test ToolShed](https://testtoolshed.g2.bx.psu.edu/)

Please check [planemo's documentation site](http://planemo.readthedocs.io/en/latest/publishing.html) for more details.

* Within the tool directory, `planemo shed_init` command can be used to bootstrap a `.shed.yml` file.

```bash
planemo shed_init --name=<name>
                  --owner=<shed_username>
                  --description=<short description>
                  [--remote_repository_url=<URL to .shed.yml on github>]
                  [--homepage_url=<Homepage for tool.>]
                  [--long_description=<long description>]
                  [--category=<category name>]*
```

* **Create tool repository on ToolShed or Test ToolShed**

```bash
planemo shed_create --shed_target testtoolshed
```

* **Update a tool repository**

```bash
planemo shed_diff --shed_target testtoolshed
```