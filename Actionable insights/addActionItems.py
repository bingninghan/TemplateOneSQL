import requests
import json
import os
import sys
from dotenv import load_dotenv


def getAuthKey():
    instance_type = os.getenv('ORCH_INSTANCE_TYPE')
    
    # Check whether the instance type is filled correctly in the configuration file.
    if instance_type != '1' and instance_type != '2':
        sys.exit("ORCH_INSTANCE_TYPE is not filled correctly in the configuration file.") 

    url = os.getenv('ORCH_URL')
    app_id = os.getenv('ORCH_APP_ID')
    app_secret = os.getenv('ORCH_APP_SECRET')

    if instance_type == '1':
        auth_endpoint = url + '/identity/connect/token'
    else:
        auth_endpoint = 'https://cloud.uipath.com/identity_/connect/token'

    # Check whether the app ID and app secret are filled in the configuration file.
    if app_id == '' or app_secret == '':
        sys.exit("ORCH_APP_ID and/or ORCH_APP_SECRET are not filled in the configuration file.")

    body = {
        "grant_type": "client_credentials",
        "client_id": app_id,
        "client_secret": app_secret,
        "scope": "OR.Tasks"
    }

    # Get the authentication key.
    req = requests.post(auth_endpoint, body)
    resJson = req.json()

    if req.status_code == 200:
        return resJson["access_token"]
    else:
        sys.exit("Request for the authentication key is not successful with status code: " + str(req.status_code) + ".")

def checkActionInput(action_input):
    # First check whether title is present to use it in the other error messages.
    if "title" not in action_input:
        sys.exit("Mandatory field 'title' is not defined for an action.")

    if "folderID" not in action_input:
        sys.exit("Mandatory field 'folderID' is not defined for action: " + action_input["title"] + ".")

    if "priority" not in action_input:
        sys.exit("Mandatory field 'priority' is not defined for action: " + action_input["title"] + ".")

    if "catalog" not in action_input:
        sys.exit("Mandatory field 'catalog' is not defined for action: " + action_input["title"] + ".")

    if "message" not in action_input:
        sys.exit("Mandatory field 'message' is not defined for action: " + action_input["title"] + ".")


def generateTheme(priority):
    if priority == "Low":
        return "primary"
    if priority == "Medium":
        return "info"
    if priority == "High":
        return "warning"
    if priority == "Critical":
        return "danger"
    return "warning"


def generateActionData(action_input, form_template):
    form_template["components"][0]["components"][0]["defaultValue"] = action_input["message"]
    form_template["components"][0]["theme"] = generateTheme(action_input["priority"])

    action_data = {
        "formLayout": form_template,
        "title": action_input["title"],
        "priority": action_input["priority"],
        "taskCatalogName": action_input["catalog"],
        "data": {}
    }

    return action_data


def createAction(action, token, tenant, form_template):
    url = os.getenv('ORCH_URL')
    add_action_endpoint = '/forms/TaskForms/CreateFormTask'

    # Check whether the URL is filled in the configuration file.
    if url == '':
        sys.exit("ORCH_URL is not filled in the configuration file.")

    # Check whether all mandatory fields to define an action are present.
    action_input = json.loads(action)
    checkActionInput(action_input)

    # Generate the action data.
    action_data = generateActionData(action_input, form_template)

    headers = {
        "Content-Type": "application/json",
        "X-UIPATH-TenantName": tenant,
        "Authorization": "Bearer " + token,
        "X-UIPATH-OrganizationUnitId": action_input["folderID"]
    }

    # Create the action in the orchestrator.
    req = requests.post(url + add_action_endpoint, json.dumps(action_data), headers=headers)
    resJson = req.json()

    if req.status_code != 201:
        sys.exit("Request to create action is not successful with status code: " + str(req.status_code)
                 + ".\n" + resJson["message"]
                 )


if __name__ == '__main__':
    # Get location of the directory in which the orchestrator folder is placed.
    directory = os.path.abspath('.')
    path = "/".join(directory.split('\\')[:-4])

    # Setting in the connector to specify for which tenant the actions are created.
    tenant = sys.argv[2]

    # Check whether tenant is set in the connector.
    if tenant == '':
        sys.exit("Tenant is not set in the connector.")

    # Check whether the configuration file for the tenant can be found.
    if not os.path.exists(path + "/orchestrator/" + tenant + ".env"):
        sys.exit("Could not find the configuration file '<PLATFORMDIR>/orchestrator/" + tenant + ".env'.")

    # Load the orchestrator configuration file for the tenant.
    load_dotenv(path + "/orchestrator/" + tenant + ".env")

    # Get the FormTemplate.json for the layout of generated actions.
    with open(path + "/orchestrator/FormTemplate.json") as f:
        form_template = json.load(f)

    # Get the authentication key for the tenant.
    token = getAuthKey()

    # Read the input from the connector.
    actions = sys.argv[1]

    # Create the actions.
    with open(actions) as f:
        for action in f:
            createAction(action, token, tenant, form_template)
