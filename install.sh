# Create a Cluster 
gcloud container clusters create pubsub-test
# Fetch Kube Credentials
gcloud container clusters get-credentials pubsub-test
# Topic Creation and Subscription
gcloud pubsub topics create echo
gcloud pubsub subscriptions create echo-read --topic=echo
# Create a Service Account and Fetch the Key 
kubectl create secret generic pubsub-key --from-file=key.json=/home/qvamjak/pubsub/key.json
# Deploy the app with new secret , so it has access to the PUBSUB
kubectl create -f pubsubsec.yml 
kubectl get pods -l app=pubsub
# Publish Message and Test
gcloud pubsub topics publish echo --message="Hello World"
kubectl logs -l app=pubsub
# Create Cluster Role For Deployment of the Custom Adapter
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole cluster-admin --user "$(gcloud config get-value account)"

# Create the Adapter
kubectl create -f https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter.yaml

# Deploy HPA

kubectl create -f pubsubhpa.yml 

# Generate Load

for i in {1..200}; do gcloud pubsub topics publish echo --message="Autoscaling #${i}"; done

# Watch the HPA 

kubectl get deployment pubsub

kubectl describe hpa pubsub

# Delete the setup 

gcloud pubsub subscriptions delete echo-read
gcloud pubsub topics delete echo
gcloud container clusters delete pubsub-test
