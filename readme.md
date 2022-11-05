# Motivation
Ever had the trouble just right after starting your work day to have your power line shut off? And then learning that outage will continue until late afternoon.
Well, it was all planned in advance, only if you knew... Now you can! And you don't need to check any website manually.

# Purpose
This suite of scripts allows you to retrieve schedule for planned maintenance in the power grid for regions (and town areas) of interest in Northeastern Bulgaria.

# What's in the box

To build a report in convenient format a nested invocation of a series scripts is structured in the following way, starting from the innermost:

## Get-Interruptions
The most basic query for straight retrieval of (almost) raw response, only serialized from Json to PS objects. Filters by region and additional simple text pattern can be supplied. Same filters can also be applied to all other scripts that depend on this script.

## Get-Interruptions-Parsed
Exracts date and time information (via regular expressions) from the raw response.

## Get-Interruptions-Report
Uses date and time information to restructure the information into a report containing upcoming time frames of interruption in service in chronological order.

## Get-Interruptions-Html
Collected report is rendered into a simple HTML table, which can be further e-mailed or otherwise brought to the attention of any interesed party.

## Get-Interruptions-Demo-Asparuhovo
An example scenario where in case there are any upcoming interruptions in service then a web browser is launched to display collected report.
