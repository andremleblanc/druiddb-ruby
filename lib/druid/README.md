# Druid
This module contains all logic associated with Druid.

## Node
The `Node` classes represent Druid nodes and manage connection with them. They
also provide the methods that are exposed natively by the Druid REST API.

## Query
The query module provides a way for the `Druid::Client` to inherit the methods
from the `Node` classes. Additionally, the `Query` module classes provide some
additional methods not found natively in the Druid REST API.

## Writer
The `Writer` classes utilize the Tranquility Kafka API to communicate with Druid
nodes and allows writing.

## Errors
**Client Error:** Indicates a failure within the JRuby-Druid adapter.  
**Connection Error:** Indicates a failed request to Druid.  
**QueryError:** Indicates a malformed query.
