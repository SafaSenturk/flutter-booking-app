# Seeds the Glow Studio catalog (services + staff) into Firestore.
#
# Catalog documents are read-only for app users (see firestore.rules), so this
# script writes with the project owner's credentials from the Firebase CLI:
#   firebase login
#   python tool/seed_catalog.py glow-booking-portfolio
import json
import os
import sys
import urllib.request

PROJECT = sys.argv[1] if len(sys.argv) > 1 else 'glow-booking-portfolio'
cfg = json.load(open(os.path.expanduser('~/.config/configstore/firebase-tools.json'), encoding='utf-8'))
TOKEN = cfg['tokens']['access_token']
BASE = f'https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents'

SERVICES = [
    # id, category, en, tr, minutes, price (TRY), icon
    ('womens-cut', 'hair', "Women's haircut", 'Kadın saç kesimi', 60, 900, 'content_cut'),
    ('mens-cut', 'hair', "Men's haircut", 'Erkek saç kesimi', 30, 500, 'content_cut'),
    ('blow-dry', 'hair', 'Blow-dry & styling', 'Fön ve şekillendirme', 30, 450, 'air'),
    ('colour', 'hair', 'Hair colouring', 'Saç boyama', 120, 2400, 'palette'),
    ('manicure', 'nails', 'Classic manicure', 'Klasik manikür', 30, 400, 'back_hand'),
    ('gel-pedicure', 'nails', 'Gel pedicure', 'Kalıcı oje pedikür', 60, 750, 'spa'),
    ('facial', 'skin', 'Signature facial', 'İmza cilt bakımı', 60, 1200, 'face'),
    ('makeup', 'makeup', 'Event makeup', 'Özel gün makyajı', 60, 1500, 'brush'),
]

STAFF = [
    ('elena', 'Elena Ruiz', 'Senior stylist', 'Kıdemli kuaför', 4.9, 2, ['womens-cut', 'mens-cut', 'blow-dry']),
    ('zeynep', 'Zeynep Aksoy', 'Colour specialist', 'Renk uzmanı', 4.8, 1, ['colour', 'womens-cut', 'blow-dry']),
    ('melis', 'Melis Kara', 'Nail artist', 'Tırnak sanatçısı', 4.9, 3, ['manicure', 'gel-pedicure']),
    ('aylin', 'Aylin Şahin', 'Skin & makeup', 'Cilt ve makyaj', 5.0, 0, ['facial', 'makeup']),
]


def val(v):
    if isinstance(v, bool):
        return {'booleanValue': v}
    if isinstance(v, int):
        return {'integerValue': str(v)}
    if isinstance(v, float):
        return {'doubleValue': v}
    if isinstance(v, str):
        return {'stringValue': v}
    if isinstance(v, list):
        return {'arrayValue': {'values': [val(x) for x in v]}}
    raise TypeError(v)


def put(path, data):
    body = json.dumps({'fields': {k: val(x) for k, x in data.items()}}).encode()
    req = urllib.request.Request(f'{BASE}/{path}', data=body, method='PATCH', headers={
        'Authorization': f'Bearer {TOKEN}', 'Content-Type': 'application/json'})
    urllib.request.urlopen(req).read()


for order, (sid, cat, en, tr, minutes, price, icon) in enumerate(SERVICES):
    put(f'services/{sid}', {'category': cat, 'nameEn': en, 'nameTr': tr, 'durationMin': minutes,
                            'price': price, 'icon': icon, 'order': order})
for order, (sid, name, role_en, role_tr, rating, color, services) in enumerate(STAFF):
    put(f'staff/{sid}', {'name': name, 'roleEn': role_en, 'roleTr': role_tr, 'rating': rating,
                         'colorIndex': color, 'services': services, 'order': order})
print(f'Seeded {len(SERVICES)} services and {len(STAFF)} staff into {PROJECT}.')
