# ZK-Voting
## limit the voting period of each Ballot contract to 5 minutes. To do so , 
### implement the following: 1- Add a state variable startTime to record the voting start time. 
### 2- Create a modifier voteEnded that will check if the voting period is over.
### 3- Use that modifier in the vote function to forbid voting and revert the transaction after the deadline.
