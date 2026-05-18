# Capstone reflection

## 1. What did you get wrong?

The earliest scaffold treated `functions/kk-payments` as a Lambda, even though Week 9 already established `kk-payments` as the Kubernetes payments service. That naming collision would have failed a demo when reviewers asked which component writes to S3. The better approach — which we adopted — is a single producer in `services/kk-payments/` and exactly three Lambdas in the receipt chain. I should have mapped Week 9 and Week 10 component names on paper before creating any directories.

## 2. Most important thing learned

**Environment separation via Kustomize overlays** (Week 9, extended in the capstone) was the concept that changed how I think about configuration management.

Before Week 9, my instinct was to copy a manifest and edit the copy for each environment — one file for staging, one for production. That works until the files drift apart and you are maintaining two versions of the same truth. Kustomize showed me that a base plus a small patch is always better than a copy. The capstone forced me to apply that same idea at two layers simultaneously: K8s namespaces used Kustomize overlays for `DB_HOST` and `RECEIPTS_BUCKET`, while the Serverless Framework used `--stage staging` and `--stage production` for the same reason at the Lambda layer.

What actually changed in my thinking: I no longer see "staging" and "production" as two separate things to build. I now see them as one base with two sets of values. That shift applies to every system I will configure after this course, not just Kubernetes.

## 3. If you had a second pass, what would you add, remove, or change?

| Change | Component | Why |
|--------|-----------|-----|
| Add | IRSA on EKS instead of `kk-payments-aws` static keys | Removes long-lived credentials from the cluster |
| Add | DynamoDB idempotency table in `kk-processor` | Prevents double-processing on S3 retry events |
| Remove | Direct `kubectl apply` from Jenkins offline stage | Use GitOps (Argo CD) so cluster state always matches git |
| Change | `kk-analytics` to incremental aggregates | Listing all S3 keys on every event will not scale past demo volume |

---

_Submitted after live presentation. AWS account activation was pending during the build week; offline validation via `serverless package` and `kubectl kustomize` proves the pipeline design. Cloud deploy is the final integration step pending credentials._
