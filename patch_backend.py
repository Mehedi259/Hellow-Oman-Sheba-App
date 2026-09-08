import os

views_path = "/Users/mehedihasanmridul/Backend/ShebaWebsiteBackend/users/views.py"
urls_path = "/Users/mehedihasanmridul/Backend/ShebaWebsiteBackend/users/urls.py"

with open(views_path, 'r') as f:
    views_content = f.read()

new_view = """
class UserJobApplicantsView(APIView):
    \"\"\"Retrieve applications submitted to the jobs posted by the current user\"\"\"
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        apps = JobApplication.objects.filter(job__user=user).select_related('job', 'user')
        res = []
        for app in apps:
            res.append({
                'id': app.id,
                'job_id': app.job.id,
                'job_title': app.job.title_bn or app.job.title,
                'applicant_id': app.user.id,
                'applicant_name': app.user.get_full_name() or app.user.username,
                'applicant_email': app.user.email,
                'applicant_phone': getattr(app.user, 'phone', ''),
                'cover_letter': app.cover_letter,
                'cv_url': app.cv_url.url if app.cv_url else None,
                'status': app.status,
                'created_at': app.created_at,
            })
        return Response(res)
"""

if 'class UserJobApplicantsView' not in views_content:
    with open(views_path, 'a') as f:
        f.write("\n" + new_view + "\n")
    print("Added UserJobApplicantsView to views.py")

with open(urls_path, 'r') as f:
    urls_content = f.read()

if 'job-applicants/' not in urls_content:
    urls_content = urls_content.replace(
        "path('applications/', views.UserJobApplicationsView.as_view(), name='user-applications'),",
        "path('applications/', views.UserJobApplicationsView.as_view(), name='user-applications'),\n    path('job-applicants/', views.UserJobApplicantsView.as_view(), name='user-job-applicants'),"
    )
    with open(urls_path, 'w') as f:
        f.write(urls_content)
    print("Added job-applicants/ to urls.py")

