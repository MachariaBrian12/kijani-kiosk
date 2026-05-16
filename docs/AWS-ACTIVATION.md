# After AWS account activation

One-time steps once https://console.aws.amazon.com shows services (not “complete registration”).

```bash
aws configure
aws sts get-caller-identity

cd ~/kijani-kiosk
./scripts/deploy-staging.sh
npm run deploy:production

# Jenkins
# Set SKIP_AWS_DEPLOY=false
```

Then complete cloud-only demos:

1. CloudWatch — three Lambda log groups after `./scripts/upload-test-receipt.sh staging`  
2. K8s — create secrets, `./scripts/k8s-deploy-staging.sh`, `./scripts/smoke-k8s-payment.sh`  
3. Update `docs/governance-checklist.md` with live ARNs from `serverless info`  
4. Screenshot Jenkins production approval with reason filled in  
5. Annotated tag: `git tag -a v1.0.0 -m "Capstone release" && git push origin v1.0.0`
