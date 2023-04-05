# Instructions
See for instructions about the `load-from-file` extraction method the UiPath documentation. 

## Configuration
The input file for this connector can be found in the `data.zip` in the sample_data folder. These are tab delimited .csv files. To load them using the `load-from-file` extraction method, make sure to extract the .zip and configure the source connection in CData Sync to point to the location of the files.

Use the following custom query when creating the job:
```
    REPLICATE [Event_log_raw] SELECT * FROM [Event_log];
    REPLICATE [Cases_raw] SELECT * FROM [Cases]

```

To run the extraction method, configure and execute the `extract_cdata.ps1` file that can be found in the scripts folder.
