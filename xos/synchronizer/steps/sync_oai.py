import os
import sys
from django.db.models import Q, F
from services.oai.models import MCORDService, OAIComponent
from synchronizers.base.SyncInstanceUsingAnsible import SyncInstanceUsingAnsible

parentdir = os.path.join(os.path.dirname(__file__), "..")
sys.path.insert(0, parentdir)

class SyncOAIComponent(SyncInstanceUsingAnsible):

    provides = [OAIComponent]

    observes = OAIComponent

    requested_interval = 0

    template_name = "sync_oai.yaml"

    service_key_name = "/opt/xos/configurations/mcord/mcord_private_key"

    def __init__(self, *args, **kwargs):
        super(SyncOAIComponent, self).__init__(*args, **kwargs)

    def fetch_pending(self, deleted):

        if (not deleted):
            objs = OAIComponent.get_tenant_objects().filter(
                Q(enacted__lt=F('updated')) | Q(enacted=None), Q(lazy_blocked=False))
        else:

            objs = OAIComponent.get_deleted_tenant_objects()

        return objs

    def get_extra_attributes(self, o):
        return {"display_message": o.display_message, 
                "image_name": o.image_name}
