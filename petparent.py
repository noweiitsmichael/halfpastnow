import urllib2, json
import Category
from parse_rest.connection import register
from parse_rest.query import Queryset
from Blog import Blog
from datetime import datetime
from parse_rest.datatypes import Function, Date

def get_blogs_from_cat(url):
	cat_url =  urllib2.Request(url)
	try:
		cat_response = urllib2.urlopen(cat_url)
		blogs_data = json.loads(cat_response.read())
		return blogs_data
	except Exception, e:
		print "Error: "+url
	
def get_elements_from_post(post, category):
	if len(post) >0:
		attachments = post["attachments"]
		if (attachments != None) and (len(attachments) >0):
			attachment = attachments[0]
			post["cover_url"] = attachment["url"]
		else:
			attachment = "http://petparent.me/blog/wp-content/uploads/2014/02/vyari2ekzgty.jpg"
			post["cover_url"] = "http://petparent.me/blog/wp-content/uploads/2014/02/vyari2ekzgty.jpg"
			
		post["category"] = category
		try:
			import_to_parse(post)
		except Exception, e:
			print "Error: "+str(post["cover_url"])
		


def connect_to_parse():
	# Test creds
	# APPLICATION_ID = "LTqWsg6TDE54DPrymajaTSwsYbyOB9facrQA2wKO"
	# REST_API_KEY = "8nwr7xndnQ8lHwk4AhpCqW2juMWMrS6r4mNjRGyv"
	# MASTER_KEY = "8SkkIJa93Uslj4IgfZbOdIMJ7fHMzitfvSlfrCnI"
	# Production creds
	APPLICATION_ID = "4LJ8r1x6bT34iJcAH360QBrvrjtomkOEnw6V2ODD"
	REST_API_KEY = "Pl5Sphkn6NFqqBnV1VEZWbB6SdcEBUUlNQNqh7db"

	register(APPLICATION_ID, REST_API_KEY)

def import_to_parse(ablog):
	blog = Blog(title=ablog["title"],slug=ablog["slug"],category=ablog["category"], date_string=str(ablog["date"])[:10],date=None,url=ablog["url"],cover_url=ablog["cover_url"],blog_id=ablog["id"],photo=None)
	print "Blog_id "+str(ablog["id"])
	tmp = Blog.Query.filter(slug=ablog["slug"],category=ablog["category"])
	# print tmp
	if Queryset.count(tmp) == 0 and ablog["id"] !=693:
		blog.save()

def initial_blogs_set_up():
	all_cat_url = urllib2.Request("http://www.petparent.me/?json=get_category_index")
	response = urllib2.urlopen(all_cat_url)
	data = json.loads(response.read())
	categories =  data["categories"]
	for cat in categories:
		# print cat["slug"] +" "+cat["title"]
		page = 1
		base_url = "http://petparent.me/category/"+str(cat["slug"])+"/?include=date,title,url,attachments,slug&attachments=1&json=1&page="
		url = base_url+str(page)
		# print url
		try:
			blogs_data = get_blogs_from_cat(url)
			# print blogs_data["count"]
			posts = blogs_data["posts"]
			category = cat["title"]
			for post in posts:
				get_elements_from_post(post,category)
		except Exception, e:
			print "Error "+url
		

		try:
			while (blogs_data["count"] > 0):
				page = page +1
				url = base_url+str(page)
				# print url
				
				blogs_data = get_blogs_from_cat(url)
				# print blogs_data["count"]
				posts = blogs_data["posts"]
				for post in posts:
					get_elements_from_post(post,category)
			
		except Exception, e:
			print "Error "+url
		
			
			

def runCloudCode():
	date_object = datetime.strptime("2014-02-16 12:12:12", '%Y-%m-%d  %H:%M:%S')
	# blog = Blog(title="Test Blog",slug="test-blog",category="test category", date=date_object,url="yahoo.com",cover_url="http://petparent.me/blog/wp-content/uploads/2014/01/Oreja_de_Cerdo_Madrid_2010_0710.jpg",blog_id=1200,photo=None)
	# hello_world_func = Function("hello")
	# ret = hello_world_func()
	# print ret
	blog.save()


connect_to_parse()

initial_blogs_set_up()
# runCloudCode()



