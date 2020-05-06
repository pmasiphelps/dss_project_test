import dataiku
import pandas as pd
import requests
from requests.auth import HTTPBasicAuth
import json
import time

INSTANCE_URL = 'localhost' ### THE URL OF YOUR DSS INSTANCE HERE
PROJECT_KEY = 'MY_PROJECT'### YOUR PROJECT KEY HERE
API_KEY = 'YOUR_API_KEY' ### YOUR API KEY HERE
SCENARIO_ID = 'MY_SCENARIO' ### THE ID OF YOUR SCENARIO HERE
OUTPUT_DATASET = 'the_output' ### THE NAME OF YOUR OUTPUT DATASET HERE

@app.route('/get_variables')
def get_variables():
    r_vars = requests.get(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/variables', auth=HTTPBasicAuth(API_KEY, ''))
    var_list = json.loads(r_vars.text)['standard'].keys()
    return json.dumps(var_list)

@app.route('/run_scenario/<path:params>')
def run_scenario(params):
    variables_dict = json.loads(params)
    variables_dict = {key:value for key,value in variables_dict.items() if value!=''}
    
    # API call to update project variables
    r = requests.get(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/variables', auth=HTTPBasicAuth(API_KEY, ''))
    project_var = r.json()['standard']
    project_var = {'standard':{key:value if key not in variables_dict else (variables_dict[key]) for (key,value) in project_var.items() }}
    
    # updating project variables
    r_vars = requests.put(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/variables',data=json.dumps(project_var),auth=HTTPBasicAuth(API_KEY, ''))
    print 'updating project variables, status code %s' % r_vars.status_code
    
    # Running flow
    r_scenario = requests.post(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/scenarios/'+SCENARIO_ID+'/run', auth=HTTPBasicAuth(API_KEY, ''))
    running = True
    
    while running == True :
        r_status = requests.get(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/scenarios/'+SCENARIO_ID+'/light', auth=HTTPBasicAuth(API_KEY, ''))
        running = r_status.json()['running']
        time.sleep(2)
    
    r_outcome = requests.get(INSTANCE_URL+'/public/api/projects/'+PROJECT_KEY+'/scenarios/'+SCENARIO_ID+'/get-last-runs/?limit=1', headers={'content-type':'json'} , auth=HTTPBasicAuth(API_KEY, ''))
    outcome = r_outcome.json()[0]['result']['outcome']
    
    if outcome == 'SUCCESS':
        df = dataiku.Dataset(OUTPUT_DATASET).get_dataframe().head(200)
        
        return json.dumps({"status": "ok", "response":project_var, "data": df.to_html(classes=['table'], border=0),\
                           "link": INSTANCE_URL+'/projects/'+PROJECT_KEY+'/datasets/'+OUTPUT_DATASET+'/explore/' })
    else :
        raise ValueError("ERROR WHILE RUNNING THE SCRIPT")