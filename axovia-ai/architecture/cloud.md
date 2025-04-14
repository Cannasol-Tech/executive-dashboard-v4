# Disaggregated Agentic Systems Cloud Architecture

This document outlines the architecture for implementing a secure, cost-effective, and scalable AI agent system using Google Cloud Platform's serverless offerings.

## Core Architectural Principles

1. **Disaggregated Components**: Break down monolithic LangGraph workflows into individual serverless functions
2. **Project Isolation**: Maintain security boundaries between application projects and shared AI resources
3. **Cost Attribution**: Track and attribute AI resource usage to source projects
4. **Stateless Design**: Use external state storage (Firestore) for workflow persistence
5. **Event-Driven Communication**: Use Pub/Sub for asynchronous agent communication

## Cloud Architecture

### GCP Service Accounts and IAM Policies

### Creating Custom Interface Roles

```bash
# Create custom role for email interface access
gcloud iam roles create EmailInterfaceRole \
  --project=axovia-agentic-core \
  --title="Email Interface Role" \
  --description="Access to email analysis API endpoints" \
  --permissions="cloudfunctions.functions.invoke,run.routes.invoke" \
  --stage=GA

# Assign role to client service account (email-manager-interface@client-project-id.iam.gserviceaccount.com)
gcloud projects add-iam-policy-binding agentic-core \
  --member="serviceAccount:axovia-email-interface@client-project-id.iam.gserviceaccount.com" \
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
    x-google-audiences: "https://agentic-api.endpoints.axovia-agentic-core.cloud.goog"

paths:
  /v1/analyze-email:
    post:
      # ...
      security:
        - google_id_token: []
      # ...
```

## Serverless Cloud Functions (for Disaggregated LangGraph)

### VPC Connector
    - Virtual Private Cloud (VPC) Connector.
    - Can be used to give an AI Agent access to resource that shouldn't be exposed to the public.
        - Example: Maybe the Email Manager's Firestore Database
    - Can start without while the architecture is still simple and being designed.
    - Should be added later to ensure strict security.

(External Request) → (API Gateway) → **[VPC Boundary]** → (Cloud Function) → [Service Account Permissions] → (LLM API)
                   |                |                 |                      |
                   Identity         Network          Identity                API 
                   Check            Check            Assumption              Check


You're absolutely right! **The VPC boundary is optional**, and Cloud Functions can be set up to be directly accessible from the internet.


**Three main ingress security settings for Cloud Functions:**

1. **ALLOW_ALL** (default): Function can be accessed through public API Call
2. **INTERNAL_ONLY**: Function can only be accessed from within your VPC Network
3. **INTERNAL_AND_GCLB**: Function can be accessed from within VPC or via GCLB (Load Balancer)
    Note: Google Cloud Load Balancer provides internet accessibility with enterprise-grade security controls.

So the simplified architecture could be:
```
**External Request → Cloud Function → [Service Account Permissions] → LLM API**
```
Many simpler deployments use this approach. The VPC boundary becomes important when:
    1. You're working with sensitive data that requires higher security
    2. You have compliance requirements (SOC2, HIPAA, etc.)
    3. You're connecting to existing private resources
    4. You want to prevent data exfiltration

For testing and initial development, direct public access is often much simpler to work with. You can always add VPC boundaries later as your security requirements evolve.


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
    "EVENT_TOPIC": "projects/axovia-agentic-core/topics/agent-transitions",
    "VERTEX_AI_LOCATION": "us-central1"
  }
}
```



## Project Structure

```
├── ai-agents-core (GCP Project)
│   ├── Agent Functions (Cloud Functions)
│   │   ├── email-analyzer
│   │   ├── content-generator
│   │   ├── data-processor
│   │   └── decision-engine
│   ├── Models & Embeddings (Vertex AI)
│   ├── Shared Libraries (Artifact Registry)
│   └── Cross-project API Gateway (Cloud Endpoints/API Gateway)
│
├── email-manager (GCP Project)
│   ├── Email Processing Services
│   ├── User Authentication
│   ├── Application-specific Data (Firestore)
│   ├── AI Agent Client Library
│   └── API for Executive Dashboard (Cloud Functions)
│
└── executive-dashboard (GCP Project)
    ├── Dashboard UI (Firebase Hosting)
    ├── Analytics Services
    ├── User Authentication
    ├── Application-specific Data (Firestore)
    └── External API Clients (including email-manager client)
```

## GitHub Repository Organization

To complement the cloud architecture, the codebase should be organized into multiple repositories within a GitHub organization rather than a monolithic repository:

```
github.com/your-org/                           # Parent GitHub Organization
├── agentic-core/                              # Common infrastructure & framework 
├── agentic-email-processor/                   # Email-specific agent implementation
├── agentic-content-creator/                   # Content creation agent implementation
├── agentic-analytics-processor/               # Analytics processing agent implementation
└── agentic-libraries/                         # Shared libraries & utilities
    ├── agent-state-management/                # State persistence utilities
    ├── prompt-engineering/                    # Reusable prompts and chains
    └── security-utils/                        # Authentication & encryption utilities
```

### Repository Responsibilities

#### agentic-core Repository

The `agentic-core` repository should not contain domain-specific agents but rather serve as a framework built on top of LangChain/LangGraph with organization-specific additions:

1. **Base Agent Patterns & Abstractions**
   - Serverless-adapted AgentExecutor wrappers
   - Cloud-specific state persistence mechanisms
   - Disaggregated workflow managers

2. **Infrastructure Components**
   - Terraform modules for agent deployment
   - API Gateway configurations
   - Security and authentication frameworks
   - Cost attribution mechanisms

3. **Interfaces and Adapters**
   - Standardized API contracts for agent services
   - LangChain adapters for serverless environments
   - Cloud service wrappers (Vertex AI, etc.)

Instead of replacing LangChain, `agentic-core` builds upon it:

```python
# Example from agentic-core
from langchain.agents import create_react_agent
from langchain.chains import LLMChain

class ServerlessAgentExecutor:
    """Adapts LangChain agents for serverless execution with state management"""
    
    def __init__(self, agent_builder_fn, tools, state_store, billing_project):
        self.agent_builder_fn = agent_builder_fn
        self.tools = tools
        self.state_store = state_store  # Firestore adapter
        self.billing_project = billing_project  # For cost attribution
        
    def handle_function_request(self, request):
        """Entry point for Cloud Function"""
        # Extract state, setup cost attribution
        execution_id = request.get_json().get('executionId')
        state = self.state_store.get_state(execution_id)
        
        # Initialize LangChain agent with current state
        agent = self.agent_builder_fn(state.get('agent_state', {}))
        
        # Run the agent with proper billing attribution
        with billing_context(self.billing_project):
            result = agent.run(state.get('input'))
            
        # Update state
        self.state_store.update_state(execution_id, {
            'result': result,
            'agent_state': agent.get_state()
        })
        
        return jsonify({'status': 'success', 'executionId': execution_id})
```

#### Domain-Specific Repositories

Each domain-specific repository (like `agentic-email-processor`) implements the actual agents using the core framework:

```python
# Example from agentic-email-processor
from agentic_core import ServerlessAgentExecutor, FirestoreStateStore
from langchain.agents import create_react_agent
from langchain_core.prompts import ChatPromptTemplate

# Create domain-specific tools
email_tools = [
    SummarizeEmailTool(),
    DetectIntentTool(),
    GenerateResponseTool()
]

# Define agent builder
def build_email_agent(state=None):
    prompt = ChatPromptTemplate.from_template("""
        You are an email processing assistant.
        Current conversation: {state}
        
        Task: {input}
    """)
    return create_react_agent(vertex_ai_llm, email_tools, prompt)

# Create serverless executor
email_processor = ServerlessAgentExecutor(
    agent_builder_fn=build_email_agent,
    tools=email_tools,
    state_store=FirestoreStateStore("agent_executions"),
    billing_project="email-manager"
)

# Cloud Function entry point
def process_email(request):
    return email_processor.handle_function_request(request)
```

#### AI Agent Client Library

The AI Agent Client Library in application projects like `email-manager` provides a clean interface for applications to use the agent services:

```python
# Example AI Agent Client Library in email-manager
class AIAgentClient:
    """Client for interacting with AI agent services"""
    
    def __init__(self, api_endpoint, service_account_path=None):
        self.api_endpoint = api_endpoint
        self.service_account_path = service_account_path
        
    async def analyze_email(self, email_id, subject, content, priority="normal"):
        """Send email for AI analysis"""
        token = self._get_auth_token()
        
        response = await httpx.post(
            f"{self.api_endpoint}/v1/analyze-email",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "source": "email-manager",
                "emailId": email_id,
                "subject": subject,
                "content": content,
                "priority": priority
            }
        )
        
        if response.status_code == 202:  # Async processing
            execution_id = response.json()["executionId"]
            return self._create_pending_result(execution_id)
        else:
            return response.json()["result"]
            
    def _get_auth_token(self):
        """Generate OAuth token for cross-project auth"""
        audience = self.api_endpoint
        auth_client = google.auth.transport.requests.Request()
        token = google.auth.iam.Credentials.from_service_account_file(
            self.service_account_path,
            target_scopes=[audience]
        ).with_target_audience(audience).get_access_token(auth_client)
        return token.access_token
        
    def _create_pending_result(self, execution_id):
        """Create a future for async result handling"""
        # Implementation for handling async results
        pass
```

### Benefits of Multi-Repository Approach

1. **Clear Functional Boundaries**
   - Each agent system has a single, well-defined purpose
   - Teams can own specific agent capabilities

2. **Independent Deployment Cycles**
   - Update email processing without affecting content creation
   - Test individual agent systems in isolation

3. **Granular Access Control**
   - Restrict sensitive agent systems to specific teams
   - Broader access to more general utilities

4. **Scalable Collaboration Model**
   - Multiple teams can work simultaneously with fewer merge conflicts
   - Clear ownership responsibilities

5. **Alignment with Cloud Architecture**
   - Repository boundaries match GCP project boundaries
   - Consistent security and isolation model

## Communication Patterns

### 1. Secure API Gateway Pattern
```
Email Manager → API Gateway → AI Agents Core → API Gateway → Email Manager
```

- **AI Agents Core** exposes a versioned API through Cloud Endpoints/API Gateway
- **Each client application** authenticates with a service account specific to that application
- **OAuth2 token exchange** for secure service-to-service communication
- **Rate limiting** and quotas enforced at the API gateway level

### 2. Pub/Sub for Asynchronous Processing

```
Email Manager → Pub/Sub → AI Agents Core
                                 ↓
Executive Dashboard ← Pub/Sub ← AI Agents Core
```

- **Topic-based communication** with separate topics per application
- **Subscription filtering** to ensure data isolation
- **Push subscriptions** to secure endpoints

## Data Flow Example: Email Processing

1. **Email Received**
   - Email-manager receives new email
   - Basic metadata processing occurs within project

2. **AI Analysis Request**
   ```json
   // POST to ai-agents-core API Gateway
   {
     "requestId": "em-123456",
     "source": "email-manager",
     "operation": "analyze-email",
     "data": {
       "emailId": "em-123456",
       "subject": "Q3 Sales Report",
       "anonymizedContent": "...",
       "priority": "high"
     },
     "responseDestination": "projects/email-manager/topics/ai-analysis-results"
   }
   ```

3. **AI Processing**
   - AI-agents-core processes email without storing raw content
   - Uses Cloud Functions for processing, Firestore for transient state
   - Returns results through Pub/Sub to specified destination

4. **Result Integration**
   - Email-manager receives analysis results
   - Updates its own database with insights
   - Calls executive-dashboard API with relevant KPIs/metrics

5. **Dashboard Update**
   - Executive-dashboard receives metrics
   - Updates dashboard views without accessing original emails

## Security Boundaries

### 1. Service Account Isolation
- Each project has dedicated service accounts
- AI-agents-core only accepts requests from whitelisted accounts
- Principle of least privilege enforced with IAM conditions

### 2. VPC Service Controls
```
Perimeter 1: email-manager resources
Perimeter 2: executive-dashboard resources  
Perimeter 3: ai-agents-core resources

Bridge 1: email-manager ↔ ai-agents-core (restricted APIs only)
Bridge 2: executive-dashboard ↔ ai-agents-core (restricted APIs only)
```

### 3. Data Minimization
- Only necessary data crosses project boundaries
- PII removed/anonymized before sending to AI services
- No raw data storage in ai-agents-core

## Disaggregated LangGraph Implementation

Each node in a traditional LangGraph workflow becomes its own Cloud Function:

```python
# Traditional LangGraph Implementation
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate

# Define the agent
prompt = ChatPromptTemplate.from_template("...")
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)

# Execute in a single process
result = agent_executor.invoke({"input": "analyze this email"})
```

Becomes:

```python
# Disaggregated Implementation - Router Function
def router_function(request):
    data = request.get_json()
    execution_id = data.get('executionId')
    
    # Get current state from Firestore
    state_ref = db.collection('agent_executions').document(execution_id)
    state = state_ref.get().to_dict()
    
    # Determine next step based on current state
    next_step = determine_next_step(state)
    
    # Update state
    state['next_step'] = next_step
    state_ref.update(state)
    
    return jsonify({'executionId': execution_id, 'next_step': next_step})

# Tool Function
def content_analysis_function(request):
    data = request.get_json()
    execution_id = data.get('executionId')
    
    # Get state
    state_ref = db.collection('agent_executions').document(execution_id)
    state = state_ref.get().to_dict()
    
    # Process with Vertex AI
    result = vertex_ai_client.predict(...)
    
    # Update state with result
    state['analysis_result'] = result
    state_ref.update(state)
    
    # Publish event
    topic_path = publisher.topic_path(project_id, 'agent-transitions')
    publisher.publish(topic_path, json.dumps({
        'executionId': execution_id,
        'status': 'analysis_complete'
    }).encode('utf-8'))
    
    return jsonify({'status': 'success'})
```

## Cost Attribution Methods

### 1. Resource Labels for Cost Attribution

```python
# When deploying your Cloud Function in ai-agents-core
gcloud functions deploy email-analyzer \
  --set-labels=source_project=email-manager,cost_center=email_ops \
  --service-account=sa@ai-agents-core.iam.gserviceaccount.com
```

Labels will appear itemized in your billing reports, allowing you to filter costs by source_project="email-manager".

### 2. Billable Project Specification

When making cross-project API calls, explicitly set the billable project:

```python
# In the API gateway or wrapper function in ai-agents-core
def process_request(request):
    calling_project = request.headers.get('X-Goog-User-Project')
    
    # Call Vertex AI with billing directed to the calling project
    vertex_client = aiplatform.gapic.PredictionServiceClient(
        client_options={
            "api_endpoint": "us-central1-aiplatform.googleapis.com",
            "quota_project_id": calling_project  # This directs the billing
        }
    )
```

### 3. Detailed Cloud Billing Export to BigQuery

Set up billing export to create a detailed record of all costs:

```sql
-- Query to show AI usage costs by source project
SELECT
  project.id AS project_id,
  labels.value AS source_project,
  service.description,
  SUM(cost) AS total_cost
FROM `billing_dataset.gcp_billing_export_v1_XXXXXX`
WHERE 
  service.description LIKE '%Vertex AI%'
  AND labels.key = 'source_project'
GROUP BY project_id, source_project, service.description
ORDER BY total_cost DESC
```

### 4. API Gateway with Metering

Implement an API Gateway in front of your AI services that tracks usage per calling service account:

```yaml
# In API Gateway configuration
x-google-management:
  metrics:
    - name: "ai-requests-per-source"
      displayName: "AI Requests Per Source Project"
      valueType: INT64
      metricKind: DELTA
  quota:
    limits:
      - name: "ai-requests-per-source-project"
        metric: "ai-requests-per-source"
        unit: "1/min/{project}"
        values:
          "email-manager": 100
          "executive-dashboard": 50
```

## Implementation Details

### Cloud Workflows for Orchestration

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
          name: projects/ai-agents-core/databases/(default)/documents/agent_executions/$${execution_id}
          body:
            fields:
              state:
                stringValue: $${json.encode(state)}
    
    - router:
        call: http.post
        args:
          url: https://REGION-ai-agents-core.cloudfunctions.net/agent-router-function
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
          url: https://REGION-ai-agents-core.cloudfunctions.net/content-writer-function
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
          name: projects/ai-agents-core/databases/(default)/documents/agent_executions/$${execution_id}
        result: final_state
        return: $${final_state.fields.state.stringValue}
```

### Cross-Project Authentication

```python
# In email-manager
def get_ai_client_token():
    audience = "https://ai-agents-api.endpoints.ai-agents-core.cloud.goog"
    auth_client = google.auth.transport.requests.Request()
    token = google.auth.iam.Credentials.from_service_account_file(
        "email-manager-to-ai-service-account.json",
        target_scopes=[audience]
    ).with_target_audience(audience).get_access_token(auth_client)
    return token.access_token
```

### AI Agent API Gateway Configuration

```yaml
# openapi.yaml for Cloud Endpoints
swagger: '2.0'
info:
  title: AI Agents API
  description: API for AI agent services
  version: 1.0.0
host: ai-agents-api.endpoints.ai-agents-core.cloud.goog
schemes:
  - https
produces:
  - application/json
security:
  - api_key: []
securityDefinitions:
  api_key:
    type: "apiKey"
    name: "key"
    in: "query"
  google_id_token:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://accounts.google.com"
    x-google-jwks_uri: "https://www.googleapis.com/oauth2/v3/certs"
    x-google-audiences: "https://ai-agents-api.endpoints.ai-agents-core.cloud.goog"
paths:
  /v1/analyze-email:
    post:
      operationId: analyzeEmail
      description: Analyze email content
      x-google-backend:
        address: https://us-central1-ai-agents-core.cloudfunctions.net/email-analyzer
      security:
        - api_key: []
        - google_id_token: []
      parameters:
        - name: body
          in: body
          required: true
          schema:
            type: object
            properties:
              source:
                type: string
              emailId:
                type: string
              content:
                type: string
      responses:
        '200':
          description: Successful response
          schema:
            type: object
            properties:
              result:
                type: object
```

## Deployment and Operations

### Function Deployment Script

```bash
#!/bin/bash
# Deploy a disaggregated agent function with proper labeling

FUNCTION_NAME=$1
SOURCE_PROJECT=$2
MEMORY=${3:-"8GB"}
TIMEOUT=${4:-"540s"}

gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime=python310 \
  --trigger-http \
  --memory=$MEMORY \
  --timeout=$TIMEOUT \
  --service-account=ai-agents-service@ai-agents-core.iam.gserviceaccount.com \
  --set-labels=source_project=$SOURCE_PROJECT,env=prod \
  --ingress-settings=internal-only \
  --entry-point=handle_request
```

### Monitoring Dashboard (Terraform)

```hcl
resource "google_monitoring_dashboard" "agent_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "AI Agents Performance",
  "gridLayout": {
    "widgets": [
      {
        "title": "Function Executions by Source Project",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_function\" metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" resource.label.\"function_name\"=monitoring.regex.full_match(\".*\")",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": ["metadata.user_labels.\"source_project\""]
                  }
                }
              }
            }
          ]
        }
      },
      {
        "title": "Execution Times",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_function\" metric.type=\"cloudfunctions.googleapis.com/function/execution_times\" resource.label.\"function_name\"=monitoring.regex.full_match(\".*\")",
                  "aggregation": {
                    "perSeriesAligner": "ALIGN_PERCENTILE_99",
                    "crossSeriesReducer": "REDUCE_MEAN",
                    "groupByFields": ["metadata.user_labels.\"source_project\""]
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
EOF
}
