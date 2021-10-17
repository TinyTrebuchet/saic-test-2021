# Task4: Create a script that performs git-auto pull from a remote git repository.
1. Firstly, I forked a flask-demo repository for this from anij12/flask-demo.
2. The script firstly fetches from the local repository, checks if there's a difference between the master and origin branch, and if so merges the newly downloaded repository into the main branch.
3. Since server configuration will be different for different backends and different systems, this script might not work for other cases. For this case, I ran the flask server on localhost by: `python3 main.py`
4. To redeploy the server, the script finds the instance and pid of main.py, kills it, and runs the same command again. Again, redeployment for different server configurations will be different.
