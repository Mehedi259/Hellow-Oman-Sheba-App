import os

file_path = "/Users/mehedihasanmridul/Backend/ShebaWebsiteBackend/users/views.py"
with open(file_path, "r") as f:
    content = f.read()

old_code = """from classifieds.models import Job, Property, Vehicle, Service, JobApplication
from classifieds.serializers import JobSerializer, PropertySerializer, VehicleSerializer, ServiceSerializer

class UserMyPostsView(APIView):
    \"\"\"Retrieve all posts created by the authenticated user\"\"\"
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        from django.db.models import Q
        user_filter = Q(user=user)
        if user.email:
            user_filter |= Q(contact_email__iexact=user.email)
        if user.phone:
            user_filter |= Q(contact_phone=user.phone)

        jobs = JobSerializer(Job.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        properties = PropertySerializer(Property.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        vehicles = VehicleSerializer(Vehicle.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        services = ServiceSerializer(Service.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        
        # Tag items with category type
        for item in jobs: item['post_type'] = 'job'
        for item in properties: item['post_type'] = 'property'
        for item in vehicles: item['post_type'] = 'vehicle'
        for item in services: item['post_type'] = 'service'
        
        all_posts = jobs + properties + vehicles + services
        all_posts.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        return Response(all_posts)"""

new_code = """from classifieds.models import Job, Property, Vehicle, Service, JobApplication, JobSeekerProfile
from classifieds.serializers import JobSerializer, PropertySerializer, VehicleSerializer, ServiceSerializer, JobSeekerProfileSerializer

class UserMyPostsView(APIView):
    \"\"\"Retrieve all posts created by the authenticated user\"\"\"
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        from django.db.models import Q
        user_filter = Q(user=user)
        if user.email:
            user_filter |= Q(contact_email__iexact=user.email)
        if user.phone:
            user_filter |= Q(contact_phone=user.phone)

        jobs = JobSerializer(Job.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        properties = PropertySerializer(Property.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        vehicles = VehicleSerializer(Vehicle.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        services = ServiceSerializer(Service.objects.filter(user_filter).distinct(), many=True, context={'request': request}).data
        job_seekers = JobSeekerProfileSerializer(JobSeekerProfile.objects.filter(user=user).distinct(), many=True, context={'request': request}).data
        
        # Tag items with category type
        for item in jobs: item['post_type'] = 'job'
        for item in properties: item['post_type'] = 'property'
        for item in vehicles: item['post_type'] = 'vehicle'
        for item in services: item['post_type'] = 'service'
        for item in job_seekers: item['post_type'] = 'job_seeker'
        
        all_posts = jobs + properties + vehicles + services + job_seekers
        all_posts.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        return Response(all_posts)"""

if old_code in content:
    with open(file_path, "w") as f:
        f.write(content.replace(old_code, new_code))
    print("Patched successfully")
else:
    print("Old code not found")

