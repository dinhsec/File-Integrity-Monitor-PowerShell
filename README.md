# File-Integrity-Monitor-PowerShell

This is a very basic File Integrity Monitor (FIM) script for PowerShell.

A file integrity monitor PowerShell script is designed to monitor changes to files on a Windows system and alert the user or administrator when a file has been modified, added, or deleted. This can help detect malicious activity or unauthorized changes to important system files.

This FIM works by having a baseline (the trusted state of a file being monitored) and comparing the current file hashes to the hashes in the baseline, and if it detects that a hash is not the same then it will warn that a file has been modified, or missing if the file is missing from the directory being monitored, it can also detect new creations of files.
