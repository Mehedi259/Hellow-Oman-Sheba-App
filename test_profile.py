import os
import sys
sys.path.append("/Users/mehedihasanmridul/Backend/ShebaWebsiteBackend/")
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sheba_backend.settings')
django.setup()

from classifieds.models import JobSeekerProfile

try:
    p = JobSeekerProfile.objects.first()
    if p:
        print(vars(p))
except Exception as e:
    print(e)
