# Task4: Create a script that performs git-auto pull from a remote git repository.
Firstly, I forked a flask-demo repository for this from anij12/flask-demo.
The script firstly fetches from the local repository, checks if there's a difference between the master and origin branch, and if so merges the newly downloaded repository into the main branch.
Since server configuration will be different for different backends and different systems, the corresponding script might be different. For this case, I ran the flask server on localhost by: `python3 main.py`
The script first finds the instance and pid of main.py, kills it, and runs the same command again. Again, redeployment for different server configurations will be different.
