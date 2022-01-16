apiVersion: v1
kind: Service
metadata:
  name: deer-service
spec:
  ports:
  - port: 80
    targetPort: deer-port
    protocol: TCP
  selector:
    app: deer-pod
  type: LoadBalancer
