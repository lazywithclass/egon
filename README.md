# CloudWatch Logs Stream Unifier

This module combines multiple streams sorting by timestamp the lines it gets from the AWS APIs.

To run tests `make test`, node is passed the flag `--stack_trace_limit 10`, so that
stack traces are at most 10 lines long.
