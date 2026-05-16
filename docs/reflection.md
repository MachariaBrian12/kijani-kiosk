# Capstone reflection

> One page when exported to PDF. Personalise the bracketed sections before submission.

## 1. What did you get wrong?

The earliest scaffold treated **`functions/kk-payments` as a Lambda**, even though Week 9 already established **`kk-payments` as the Kubernetes payments service**. That naming collision would have failed a demo when reviewers asked which component writes to S3. The better approach — which we adopted — is a single producer in `services/kk-payments/` and exactly three Lambdas in the receipt chain. I should have mapped Week 9 and Week 10 names on paper before creating directories.

## 2. Most important thing learned

**Environment separation via Kustomize overlays** (Week 9 → capstone) changed how I think about “one manifest, many environments.” Staging and production share `k8s/base/deployment.yaml` but differ only in ConfigMap patches (`DB_HOST`, `RECEIPTS_BUCKET`). That pattern appeared in Week 9 with a single namespace; the capstone forced the same idea across **K8s namespaces and Serverless stages**, which is the same design skill at two layers.

## 3. If you had a second pass, what would you add, remove, or change?

| Change | Component | Why |
|--------|-----------|-----|
| **Add** | IRSA on EKS instead of `kk-payments-aws` static keys | Removes long-lived credentials from the cluster |
| **Add** | DynamoDB idempotency table in `kk-processor` | Prevent double-processing on S3 retry events |
| **Remove** | Direct `kubectl apply` from Jenkins offline stage | Use GitOps (Argo CD) so cluster state matches git |
| **Change** | `kk-analytics` to incremental aggregates | Listing all S3 keys on every event will not scale past demo volume |

---

_Submitted after live presentation. Honest assessment: AWS account activation was pending during build; offline validation and `serverless package` prove the pipeline, with cloud deploy as the final integration step._
