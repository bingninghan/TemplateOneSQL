# TemplateOne-cases-eventlog connector

## Extraction

###  Load from File Data Import

Detailed instructions for extractions can be found in the following document: [Load from File Extraction](../extractors/load-from-file/instructions.md).

### Input data

**Cases**

This table contains the detailed information for the status, type, value and description for the related case.

|Name           |Data type  |Mandatory Y/N  |Description                                                                                        |
|:---           |:----      |:---           |:---                                                                                               |
|case_id        |text       |Y              |The unique identifier of the case the event belongs to.                                            |
|case           |text       |N              |A user-friendly name to identify the case.                                                         |
|case_status    |text       |N              |The status of the case in the process. For example, 'open', 'closed', 'pending', 'approved', etc.  |
|case_type      |text       |N              |The categorization of the cases.                                                                   |
|case_value     |double     |N              |A monetary value related to the case.                                                              |

In addition, custom case fields are available. 30 text, 10 double, and 10 datetime fields are available for the case properties. Rename these fields in the app to a name that matches their values.

|Name                           |Data type  |Mandatory Y/N  |
|:---                           |:----      |:---           |
|custom_case_text_{1...30}      |text       |N              |
|custom_case_number_{1...10}    |double     |N              |
|custom_case_datetime_{1...10}  |datetime   |N              |

**Event_log**

The event log contains information on the activities executed in the process.

|Name           |Data type  |Mandatory Y/N  |Description                                                                                        |
|:---           |:----      |:---           |:---                                                                                               |
|activity       |text       |Y              |The name of the event. This describes the step in the process.                                     |
|case_id        |text       |Y              |The unique identifier of the case the event belongs to.                                            |
|event_end      |datetime   |Y              |The timestamp associated with the end of executing the event.                                      |
|automated      |boolean    |N              |Indicates whether the event is manually exectued or automated.                                     |
|event_detail   |text       |N              |Information related to the event.                                                                  |
|event_start    |datetime   |N              |The timestamp associated with the start of executing the event.                                    |
|team           |text       |N              |The team that executed the event.                                                                  |
|user           |text       |N              |The user who executed the event.                                                                   |

In addition, custom event fields are available. 30 text, 10 double, and 10 datetime fields are available for the event properties. Rename these fields in the app to a name that matches their values.

|Name                           |Data type  |Mandatory Y/N  |
|:---                           |:----      |:---           |
|custom_event_text_{1...30}     |text       |N              |
|custom_event_number_{1...10}   |double     |N              |
|custom_event_datetime_{1...10} |datetime   |N              |

## Connector configuration
The following fields can be configured using the csv files in the `seeds` directory.

|Name                   |Data type  |Mandatory Y/N  |Description                                                                                      |Location                     |
|:----------------------|:----------|:--------------|:------------------------------------------------------------------------------------------------|:----                        |
|Activity_order         |integer    |N              |If activities take place on the same time (in parallel), you can define their order here.        | `Activity_configuration.csv`  |
|Event_cost             |double     |N              |The costs for executing the event.                                                               | `Automation_estimates.csv`    |
|Event_processing_time  |integer    |N              |The amount of time actually spent working for the event given in milliseconds.                   | `Automation_estimates.csv`    |
