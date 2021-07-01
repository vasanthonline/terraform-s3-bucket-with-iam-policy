# terraform-s3-bucket-with-iam-policy
Terrform file to do the following steps:
1. Create a S3 bucket based on a variable bucket_name.
2. Create an IAM policy with permissions to access the bucket.
3. Create a user.
3. Associate the new IAM policy to the new user.


### Explanation
1. User assume role "ci-cd-role" via "tf-apply-policy"
2. Role "ci-cd-role" has "ci-cd-policy" to create bucket, create bucket policy, create user and assign policy to user.
3. Using role "ci-cd-role", terraform does the following:
    - Create bucket "sample-bucket-via-tf"
    - Create IAM policy "sample-bucket-via-tf-bucket-policy"
    - Create user "sample-bucket-via-tf-user"
    - Assign the new policy to the new user.
