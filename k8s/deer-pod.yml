apiVersion: v1
kind: Pod
metadata:
  name: deer
  labels:
    app: deer-pod
spec:
  containers:
  - name: k8s-deer
    image: marekszpregiel/nginx_hello_deer
    ports:
    - name: deer-port
      containerPort: 80
