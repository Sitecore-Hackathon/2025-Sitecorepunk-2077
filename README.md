# Hackathon Submission Entry form

- [Hackathon Submission Entry form](#hackathon-submission-entry-form)
  - [Team name](#team-name)
  - [Category](#category)
  - [Description](#description)
    - [Problem Statement](#problem-statement)
    - [Solving with AI](#solving-with-ai)
    - [Key Features](#key-features)
  - [Video link](#video-link)
  - [Pre-requisites and Dependencies](#pre-requisites-and-dependencies)
    - [Sitecore Requirements](#sitecore-requirements)
    - [API \& Service Dependencies](#api--service-dependencies)
  - [Installation instructions](#installation-instructions)
    - [Configuration](#configuration)
  - [Usage instructions](#usage-instructions)
    - [Alternative Usage](#alternative-usage)
  - [Comments](#comments)
    - [Future Iterations](#future-iterations)


## Team name

- Sitecorepunk 2077 
  - [@GabeStreza](https://www.x.com/GabeStreza)

![](/docs/images/sitecorepunk2077.png)

## Category

> "FREE FOR ALL" 
>  [ Sitecore PowerShell Extensions  +  OpenAI ]

## Description

The `SPExAI Report Generator` is a `Sitecore PowerShell Extensions (SPE)` module that integrates `OpenAI` LLMs to dynamically generate Sitecore PowerShell reports based on natural language input and pre-defined rules. 

### Problem Statement

Creating SPE reports traditionally requires technical expertise, knowledge of Sitecore’s API, and familiarity with SPE scripting. This can be a barrier for content authors, marketers, or non-developer teams who need reports but lack coding skills.

Without a user-friendly way to generate reports, organizations may miss out on valuable insights, struggle to track content performance, or waste time on manual data extraction.

### Solving with AI

The `SPExAI Report Generator` module streamlines the process of creating Sitecore reports by allowing users to describe their reporting needs in plain English, which in turn, generates a structured PowerShell script following Sitecore best practices.  The generated script is saved to the tree for future use and can be executed immediately or modified before running.

The hope is that it can serve as a valuable tool for developers interested in rapid SPE report prototyping, and eventually become a go-to resource for content authors, marketers, and other non-technical users who need to generate reports quickly and efficiently.

### Key Features

- ✨ **AI-Generated Reports** 
  - Users provide a plain-text description, and the system translates it into a fully functional PowerShell script.
    > ![](/docs/images/01.png)

<br/>

- 🔗 **Seamless Integration**
  - Configured as a contextual **Ribbon Button** within the **Home** > **Reports** tab in **Sitecore Content Editor**.
    > ![](/docs/images/02.png)

<br/>

- 🚅 **Immediate Execution or Customization**
  - Users can run reports instantly or modify them before execution.
    > ![](/docs/images/03.png)

    <br/>

    > ![](/docs/images/04.png)

<br/>

- ⚙ **Flexible API Configuration** 
  - Supports codeless `OpenAI` API configuration, including model selection, system prompts, and knowledge base references.
    > ![](/docs/images/05.png)

    <br/>

- 👍 **Predefined Best Practices**
  - Ensures generated scripts adhere to Sitecore PowerShell standards, maintaining structure, validation, and efficiency.

<br/>


- 🚀 **Empowers both Technical and Non-Technical Users**
  - Reduces development effort while enabling content authors and marketers to generate reports effortlessly.

<br/>

## Video link
> 🎥 [https://youtu.be/uuM1OfZ_6E0](https://youtu.be/uuM1OfZ_6E0)

<br/>

## Pre-requisites and Dependencies

Before installing the `SPExAI Report Generator`, please make sure the following requirements are met:  

### **Sitecore Requirements**  
- ⭕ Sitecore **10.x or later** 
  - Tested on Sitecore `10.0` and, `10.3` and `10.4`  but should work with earlier versions.
  - Untested on XM Cloud, but also likely compatible.

  <br/>

- 🚀 Sitecore PowerShell Extensions (SPE) `7.0`  

### **API & Service Dependencies**  

1. 🌎 Internet access
     - Sitecore must be able to connect to OpenAI’s API.

<br/>

1. 🔑 OpenAI API Key 
    - Required for AI-powered script generation. 
      - AI services are not completely cost-free, so you'll need to sign up for an API key at [OpenAI](https://platform.openai.com/). 
        - Navigate to `Settings` > `API Keys` > `Create API Key` to generate a new key.
        - > ![](/docs/images/06.png)
      - The module is pre-configured to use the `o3-mini-2025-01-31` model.
      - The model can be changed within in the `API Settings` item, but because outputs may vary, I recommend retaining this model for consistency.
      - For reference, `109` requests (`711,419` total tokens) against the  `o3-mini-2025-01-31` during the development of this model cost `$1.15` USD.

<br/>

> 👨‍⚖️ **Judges:** I've excluded my API key from the Sitecore package.  If you don't have an OpenAI account, and need a way to test this without signing up, please reach out to me on Slack and I can lend you a key!


## Installation instructions

1. Use the `Sitecore Installation Wizard` to install the [SPExAI Report Generator-1.zip](/src/SPExAI%20Report%20Generator-1.zip)

<br/>

2. After the package has completed installing, navigate to the `Desktop` > `Start Button` > `PowerShell Toolbox` > `Rebuild script integration points`
    > ![](/docs/images/07.png)

<br/>

### Configuration

Navigate to `/sitecore/system/Modules/PowerShell/Script Library/SPExAI Report Generator/API Settings` and set the `API Key` key field with your OpenAI secret key generated in the prerequisites. 

 > ![](/docs/images/08.png)

<br/>


## Usage instructions

1. Navigate to an item in the `Content Editor`.  This will be treated as the root path for the script. 

<br/>

2. In the `Ribbon`, click on the `SPExAI Report Generator` button in the `Reports` chunk of the `Home` tab. 
   > ![](/docs/images/09.png)

<br/>

3. A dialog will appear:
   > ![](/docs/images/10.png)
   1. Populate the `Report Name` field
   2. Select an item in the `Report Scope (Root Location)` field.
   3. Provide a description of the report you want to generate in the `Describe Your Report`. 

<br/>

4. After the script is generated, choose one of the options: 
   > ![](/docs/images/11.png)
   1. `Open Script Item` (opens the PowerShell script item in the `Content Editor`)
      - The generated script will be stored in the `SPExAI Generated` location where it can be modified / debugged / executed.
        > ![](/docs/images/12.png)
   2. `Run Report` (executes the script)
      - Generated scripts allow you to refine the root path before it runs:
        > ![](/docs/images/13.png)

   3. `Close` (takes no action, closes the dialog)

<br/>

5. The Generated report will appear in the `SPExAI Generated` folder from the `PowerShell Reports` section of the `Start Menu`:
   > ![](/docs/images/14.png)

<br/>

### Alternative Usage

While the `Ribbon` button is the primary method of generating reports, the `SPExAI Report Generator` can also be accessed via the right-click context menu in the `Content Editor` on any item:

> ![](/docs/images/15.png)

<br/>

## Comments

The raw PowerShell script defined in the `SPExAI Report Generator` PowerShell Module can be reviewed here:
-  [SPExAI Report Generator.ps1](/src/SPExAI%20Report%20Generator.ps1)

Included in the `src` folder is the `System Prompt` (which is integrated into the `API Settings` item) used to the achieve one-shot prompting result.
- [SPExAI_SystemPrompt.md](/src/SPExAI_SystemPrompt.md)

Finally, the supplemental `Knowledgebase` file that's dynamically included in the `System Prompt` before the request is sent to `OpenAI` can also be found in the `src` folder.  The file contains some general SPE documentation plus script examples which the model refers to in order generate reports relatively consistent format.
- [SPExAI_Knowledgebase.md](/src/SPExAI_Knowledgebase.md)

<br/>

### Future Iterations
I see future iterations of this module including more advanced features such as:
- Regenerating / iterating on existing reports/scripts.
- Improved stability and response consistency following the more advanced OpenAI (or other LLM provider) models.
- More advanced configuration options for the AI model and knowledgebase.
