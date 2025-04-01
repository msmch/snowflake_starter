# Builder Classes

This directory houses the foundational builder classes that drive the automation of a Snowflake data warehouse setup. Integrated with the `Orchestrator` class (located in `automation_scripts/orchestrator.py`), these scripts provide a programmatic approach to generating key database objects, streamlining the process from data ingestion to transformation.

## Core Functionality

The builder classes are designed to perform the following tasks in a modular and reusable manner:

1. **Staging Table DDL Generation**  
   By analyzing input files, the classes infer column data types and generate DDL statements for staging tables. This ensures compatibility between source file structures and the resulting Snowflake tables, reducing manual configuration efforts.

2. **Stage and Snowpipe Configuration**  
   The classes define Snowflake stages mapped to an Azure File Storage location and create corresponding Snowpipe objects. These pipes listen to a default notification queue, automatically loading files into staging tables as events are triggered from Azure.

3. **Stream Definitions for Change Tracking**  
   Streams are created on staging tables to monitor inserts or updates, providing a mechanism to detect and propagate changes to downstream processes efficiently.

4. **Transformed Table DDL Creation**  
   Using the predefined `TABLES_MAPPING`, the builder classes generate DDL for tables in the `transformed` schema. Only explicitly mapped tables receive definitions, ensuring a controlled and intentional transformation layer.

5. **Task and Merge Logic Automation**  
   Tasks are defined to execute MERGE commands, triggered by data detected in staging table streams. This logic ensures that `transformed` tables are updated incrementally with new or changed data, while gracefully handling potential file duplication from Azure File Storage (where Snowpipe validates uniqueness by file name only).

## Design Principles

The builder classes operate under the following assumptions and principles:
- **Data Type Inference**: Column data types for staging tables are derived programmatically from file contents, specifically the second element of space-delimited rows, ensuring adaptability to varying file formats.
- **Incremental Processing**: The pipeline supports efficient data ingestion into `raw_*` tables in the `staging` schema, with tasks merging only unique and up-to-date records into `transformed` tables.
- **Scalability**: The modular design allows the framework to handle multiple file events and scale with growing data volumes or complexity.

## Extensibility and Customization

The generated scripts serve as a starting point for a Snowflake data warehouse, offering flexibility for further refinement:
- **Staging Table Optimization**: Developers can enhance definitions by adding primary/foreign key constraints, adjusting data types, or setting default values for key generation.
- **Task Enhancements**: Task logic can be modified to include additional ELT transformations, tailoring the pipeline to specific business or analytical requirements.
- **Transformed Schema Adjustments**: The `transformed` table DDLs can be customized (e.g., altering columns or adding indexes) to better support downstream analytics objects.

## Usage

These builder classes are invoked by the `Orchestrator`, which coordinates their execution based on the project's configuration and input files. They provide a robust foundation for automating warehouse setup, while allowing developers to adapt the output to meet production needs.