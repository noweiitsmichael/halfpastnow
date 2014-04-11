class Category(object):
    name = ""
    slug = ""
   	# The class "constructor" - It's actually an initializer 
    def __init__(self, name, slug):
        self.name = name
        self.slug = slug
        