## CCDMSetter

This is a simple contract that allows you to set and get values for use with Royco Cross-Chain Deposit Module.

CCDMSetter allows a user to set one or more values which can be retrieved in the same block. The getter function is only callable by a CCDM WeirollWallet, and will only retreive values set by the market owner of a WeirollWallet's marketHash, determined by calling the CCDM ExecutionManager. The getter function will revert if the value was not set this block.
