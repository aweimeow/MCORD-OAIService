from service import XOSService
from services.oai.models import OAIService

class XOSMOAIService(XOSService):
    provides = "tosca.nodes.OAIService"
    xos_model = OAIService
    copyin_props = ["view_url", "icon_url", "enabled", "published", "public_key", "private_key_fn", "versionNumber"]

