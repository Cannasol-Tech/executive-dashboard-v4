# Google Cloud Platform Credentials

## Service Account Key (Template)
```json
{
  "type": "service_account",
  "project_id": "cannasol-executive-dashboard",
  "private_key_id": "74fddc6b01047064c505b637603132332a969e3c",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDB9HIQ8qRzZmqZ\nj015Z8eaG5YHHxZcmx4NbentlQgCTcTUCt5Cz78YArjHCepC3g77rR0Wz3+ZaS3n\n+xmpc2sJsAeUhJ4fsVMTO94+bvrPHRd2gYj73kYEL3yQrpEnNG9uQQxScZpd/UOy\nTS+7wwa4ZScb2q4g0zV5G80qMnaq7V+Li6J200HVuCRt6kcAf+KouZAMkErVwKK6\n6kSLz/iv1eFGBCYVdBniIgIjDk0ONmYTo2XOEPLlDShm9jftF5SdB/NOjLhW2mjU\nVNI4WNWhndrCvSML6LFE6ZHlV2t2oeIfBHesycXP9ATweK6NkbRb4aoqkGArr+Uu\nSJN1revNAgMBAAECggEAJ3HPfd9e7wIx5UN10d43g4GfOBkMKu64BKqpE7KGo7NN\nt4LzUzqdRiSNkBsV253+BZSeERzHejtgBOj1/dZ1ew2j6QI0h0UAnG2FRAS9eMAV\nnLn40iJQ8np21pTN+99n1xAfEag9aOaALUOR1NlzpS4bL0jAt3fEzPnIto93P0j2\n+B1eVUyWNRhCvf3f02pUETBSaW81W8NPm8SsQxbBlCHkpCsI+sMTaQWLwZIQ8wDW\n8tj7a9RmcFiDIdxB/boIbvhg8LjgUTwMaeL6Ela9uyUy+BZlFwLnGaML06KraLqW\nHgRBBXx1Pw6eLoBr7wmqp83J135g09UUPezAo/OTyQKBgQDox6aatNWu48G/EsZo\nzMCx0i3W9bdUzBJe+C9UXgZrqFZNNmdc8t519RCRhF9uGbeZxh2GhqBoS8JmvWAR\ntX8mYCOOslFF+pMGVFlVTNEtgm+O2nTvvGKy/Jn9O0lyup7peGFUGfS1Nz/5pFGb\nfdiRyMDLPWNuZVVQ/dtkjIBBJQKBgQDVTVhqHEatTIaPQvSyw5ZnhCTJ/deRVtQX\nV5sHih8Reva2GZjMHbqT18SepKZ/A12m5dQn9B3rtgqg4zmaBfGsozkII7W0k1lM\nLDO/PKLsy4KiODTRHDYQjrZl8ZtSfzrpKIKSfIc2jMS/+nxlBk9GZZ4jXwNdMA7t\n7PrnOacjiQKBgQCnf/JcZD9Wh0DE8weeJaeKzQh7I3h2JhoaCFBWTwojsY/YI4uh\nEIoPKvZvH2dj3FGG704TnRATvF/4edCFLap+vLMZXSqqRjJBXbSicpIaQz9u9bcr\nQs1qqeVMmLqzOaJbsWmnkL3LICSCyECIuLd7v48rL9M6fuQzUVfrNEadmQKBgQCa\nkJua+LZ2adewBHLQ/04D4QvPmzQUS3kRGRhsFDiDMDmKp23Dq19CNr5xvxovO78n\na6+a7Biqb5WwFDfvVpNT6EsxjL7lBUlWG0m8MDJXqPkWl+geB3Vd9ixSHwvQcgW8\nYvCLOdW5P7Rq8RYnFrVna8d2FimX43VOD8WYvHxTEQKBgQDKqoveZg3UmOOK6wY+\ncJiGs7sSVHHW8ytYPyYgBcuq7Lgx2OrDL04dMweo2V9DBP3QwxVxmYH542HEVsWr\nRWpPsqhDw+jKs5SPl6/iuIJ3cuswOno8GhUOCtv8O+P7u5tH14B2fBqFpN4WhRlg\nYZAeE126GpxexuZYcwXV6uYaSw==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-access@cannasol-executive-dashboard.iam.gserviceaccount.com",
  "client_id": "102261623936756049935",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-access%40cannasol-executive-dashboard.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}


## Service Account Structure

### Agentic Core Project Service Accounts

1. **AI Service Deployment Account**
   - **Name Format**: `ai-service-deployer@agentic-core.iam.gserviceaccount.com`
   - **Purpose**: Deploys and manages AI infrastructure components
   - **Required Roles**:
     - Cloud Functions Admin: `roles/cloudfunctions.admin`
     - Cloud Run Admin: `roles/run.admin`
     - Workflows Admin: `roles/workflows.admin`
     - Service Account User: `roles/iam.serviceAccountUser`
     - Artifact Registry Admin: `roles/artifactregistry.admin`

2. **AI Model Manager Account**
   - **Name Format**: `ai-model-manager@agentic-core.iam.gserviceaccount.com`
   - **Purpose**: Manages and accesses AI models and embeddings
   - **Required Roles**:
     - Vertex AI User: `roles/aiplatform.user`
     - Model User: `roles/aiplatform.modelUser`
     - Storage Object User: `roles/storage.objectUser`

3. **Agent Function Runtime Account**
   - **Name Format**: `agent-function-runtime@agentic-core.iam.gserviceaccount.com`
   - **Purpose**: Runtime identity for agent cloud functions
   - **Required Roles**:
     - Vertex AI User: `roles/aiplatform.user`
     - Firestore User: `roles/datastore.user`
     - Pub/Sub Publisher: `roles/pubsub.publisher`
     - Secret Manager Secret Accessor: `roles/secretmanager.secretAccessor`

### Client Project Service Accounts (for accessing AI Core)

1. **Email Subsystem Interface Account**
   - **Name Format**: `axovia-email-interface@client-project-id.iam.gserviceaccount.com`
   - **Purpose**: Accesses email analysis APIs
   - **Required Permissions** (Custom Role):
     - `aiplatform.endpoints.predict` (if direct model access needed)
     - `cloudfunctions.functions.invoke` (specific to email functions)
     - `run.routes.invoke` (if using Cloud Run)

2. **Analytics Subsystem Interface Account**
   - **Name Format**: `axovia-analytics-interface@client-project-id.iam.gserviceaccount.com`
   - **Purpose**: Accesses analytics APIs
   - **Required Permissions** (Custom Role):
     - `cloudfunctions.functions.invoke` (specific to analytics functions)
     - `run.routes.invoke` (if using Cloud Run)

3. **Content Subsystem Interface Account**
   - **Name Format**: `axovia-content-interface@client-project-id.iam.gserviceaccount.com`
   - **Purpose**: Accesses content generation APIs
   - **Required Permissions** (Custom Role):
     - `cloudfunctions.functions.invoke` (specific to content functions)
     - `run.routes.invoke` (if using Cloud Run)

## Custom Roles for Client Applications

### Creating Custom Interface Roles

```bash
# Create custom role for email interface access
gcloud iam roles create EmailInterfaceRole \
  --project=agentic-email-manager \
  --title="Email Manager Interface Role" \
  --description="Access to email manager API endpoints" \
  --permissions="cloudfunctions.functions.invoke,run.routes.invoke" \
  --stage=GA

# Assign role to client service account
gcloud projects add-iam-policy-binding axovia-agentic-core \
  --member="serviceAccount:email-manager-interface@client-project-id.iam.gserviceaccount.com" \
  --role="projects/agentic-core/roles/EmailInterfaceRole"
```

## API Gateway Access for Client Service Accounts

```yaml
# In API Gateway openapi.yaml
securityDefinitions:
  google_id_token:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://accounts.google.com"
    x-google-jwks_uri: "https://www.googleapis.com/oauth2/v3/certs"
    # Specify allowed client service accounts
    x-google-audiences: "https://agentic-api.endpoints.agentic-core.cloud.goog"

paths:
  /v1/analyze-email:
    post:
      # ...
      security:
        - google_id_token: []
      # ...
```

## Serverless Cloud Functions (for Disaggregated LangGraph)
```json
{
  "runtime": "python310",
  "memory": "8GB",
  "timeout": "540s",
  "concurrency": 80,
  "min_instances": 0,
  "max_instances": 10,
  "vpc_connector": "your-vpc-connector",
  "ingress_settings": "ALLOW_INTERNAL_ONLY",
  "environment_variables": {
    "AGENT_STATE_COLLECTION": "agent_executions",
    "EVENT_TOPIC": "projects/agentic-core/topics/agent-transitions",
    "VERTEX_AI_LOCATION": "us-central1"
  }
}
```

## Disaggregated LangGraph Implementation
Each agent/node in your LangGraph will be implemented as a separate Cloud Function:

1. **Agent Nodes**:
   - Agent Router: `agent-router-function`
   - Content Writer: `content-writer-function`
   - Fact Checker: `fact-checker-function`
   - Data Processor: `data-processor-function`
   - Output Generator: `output-generator-function`

2. **State Management**:
   - State Storage: Firestore `agent_executions` collection
   - Execution ID: Passed between functions for state tracking
   - Artifact Storage: Cloud Storage bucket

3. **Command to Deploy Agent Nodes** (with proper service account):
```
gcloud functions deploy agent-router-function \
  --gen2 \
  --runtime=python310 \
  --trigger-http \
  --memory=8GB \
  --timeout=540s \
  --service-account=agent-function-runtime@agentic-core.iam.gserviceaccount.com \
  --entry-point=router_handler
```

## Cloud Workflows Configuration
```yaml
main:
  params: [input]
  steps:
    - init:
        assign:
          - execution_id: $${sys.gen_random_uuid()}
          - state:
              executionId: $${execution_id}
              input: $${input}
              status: "PENDING"
    
    - store_initial_state:
        call: googleapis.firestore.v1.projects.databases.documents.patch
        args:
          name: projects/agentic-core/databases/(default)/documents/agent_executions/$${execution_id}
          body:
            fields:
              state:
                stringValue: $${json.encode(state)}
    
    - router:
        call: http.post
        args:
          url: https://REGION-agentic-core.cloudfunctions.net/agent-router-function
          auth:
            type: OIDC
          body:
            executionId: $${execution_id}
        result: router_result
    
    - check_router:
        switch:
          - condition: $${router_result.body.next_step == "content_writer"}
            next: content_writer
          - condition: $${router_result.body.next_step == "fact_checker"}
            next: fact_checker
          - condition: $${router_result.body.next_step == "complete"}
            next: return_result
    
    - content_writer:
        call: http.post
        args:
          url: https://REGION-agentic-core.cloudfunctions.net/content-writer-function
          auth:
            type: OIDC
          body:
            executionId: $${execution_id}
        result: writer_result
        next: check_writer
    
    # Additional steps for other functions
    
    - return_result:
        call: googleapis.firestore.v1.projects.databases.documents.get
        args:
          name: projects/agentic-core/databases/(default)/documents/agent_executions/$${execution_id}
        result: final_state
        return: $${final_state.fields.state.stringValue}
```

## Cross-Project Authentication Flow

```
Client Project:
1. Generate OIDC token for service account (axovia-email-interface@client-project-id)
2. Include token in request to AI Core API Gateway

Agentic Core Project:
1. API Gateway verifies token and service account identity
2. Agent function executed with agent-function-runtime@agentic-core identity
3. Access to models, state and other resources handled by agentic-core
```

## Pub/Sub Topics (for Event-Driven Communication)
- `projects/agentic-core/topics/agent-transitions`
- `projects/agentic-core/topics/agent-results`
- `projects/agentic-core/topics/agent-logs`
- `projects/agentic-core/topics/agent-status-changes`

## Secret Manager (for Sensitive Credentials)
- `projects/agentic-core/secrets/openai-api-key`
- `projects/agentic-core/secrets/anthropic-api-key`
- `projects/agentic-core/secrets/huggingface-api-key`
- `projects/agentic-core/secrets/pinecone-api-key`
- `projects/agentic-core/secrets/agent-encryption-key`

## Environment Variables
```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
GOOGLE_CLOUD_PROJECT=agentic-core
GOOGLE_CLOUD_REGION=us-central1
AGENT_MODEL_NAME=gemini-1.5-pro
AGENT_STATE_COLLECTION=agent_executions
AGENT_TRANSITIONS_TOPIC=agent-transitions
VERTEX_AI_LOCATION=us-central1
```

## Storage Buckets
- `gs://agentic-core-agent-models` - For storing fine-tuned models
- `gs://agentic-core-agent-data` - For storing processing data
- `gs://agentic-core-agent-artifacts` - For storing agent outputs
- `gs://agentic-core-agent-logs` - For storing detailed logs 