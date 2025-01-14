# Claim management service

## Overview

This projects consists of a simple claims management service, backed by a database with user and claim data.

It supports adding a new claim and retrieving the status of an existing claim.

### Adding a new claim

If a registered user attempts to make a claim and the user's total claims (including the new claim) don't exceed a pre-authorized amount (configurable), the claim will be added to the database in the approved state.

If the total exceeds the pre-authorized limit, the claim will be added to the database with status marked as pending, and an email will be sent to both the user and the finance team informing that there is a pending claim.

![Post a Claim](./images/post_claim.svg)

### Retrieve the status of a claim

Retrieve the status of a claim by claim ID.

![Retrieve the status of a claim](./images/claim_status.svg)
