# Web app beginner guide
This guide is meant to serve as a resource for someone who has decided that web app pentesting or web application security is the path for them. With that being said there is no guide and no one plan that will work for everyone. In fact you don't need any structured learning at all as you could just learn everything on your own, but for most the trial and error path will likely be the longer path. If you are brand new with 0 IT experience there are some places you could start for that as well. The foundations below offer learning material for some of the basics needed by everyone who is interested in IT and again there is no one stop shop or one plan for all. The material is all free and you'll get back what you put into it. Any reading or video watching is best supplemented with some hands on practice.
## Foundational

### Learn the basics for free (This is for ground zero, no IT experience)
- TCM free tier Help Desk, Soft skills, Programming, Linux Basics https://tcm-sec.com/free-tier-launch/
- Basics of hardware/operating systems (A+), networking (Network+), and cybersecurity (Security+). Take the certs if you want but the learning is all free here https://www.youtube.com/professormesser

If you are past this point and have made the decision that web app is your jam, then the rest of these resources are for you. If you have decided that you are interested in pentesting, but unsure of what exactly it is you like, I highly recommend [Practical Ethical Hacking](https://academy.tcm-sec.com/p/practical-ethical-hacking-the-complete-course) from TCM security. It is a great first pentesting course and a one stop shop to get a taste of ethical hacking in general. Another thing that should be discussed is when pursuing any job in IT especially a job like pentesting that is difficult to land as a beginner, a degree can help. Many employers allow substitution of IT work experience for a degree but many including govt contracts require a bachelors degree. Long story short, while you don't need a degree it can make life easier. I recommend [Western Governors University](https://www.wgu.edu/) (WGU). WGU allows you to move at your own pace potentially completing your degree much quicker saving a lot of time and money. It's an online university so will you miss out on the college experience? Crippling student loan debt, 4 years of greasy fast food, and sleeping in a dorm with a weird stranger? Yeah you'll miss that. 
 
My next disclaimer is that even if you have decided on web applications as your bread and butter, I highly recommend the [Penetration Tester Path](https://academy.hackthebox.com/path/preview/penetration-tester) from Hack The Box Academy. The wealth of knowledge it contains is valuable for anyone in offensive security and will keep you from one trick pony status. If you really wanted to throw the cherry on top of your resume I would recommend taking the [OSCP](https://www.offsec.com/courses/pen-200/) certification after completing the Penetration Tester Path on Hack The box Academy. It's not a web app specific certification, but you will find it on more job postings than any other penetration testing certification.

Finally getting to the topic of web app there are a few places we could start but I think the [Bug Bounty Hunter Path](https://academy.hackthebox.com/preview/certifications/htb-certified-bug-bounty-hunter) from Hack The Box Academy may be the best one stop shop I can come up with. It covers all the major topics, is well organized, and has all the labs included. The reason I chose this course is, if you follow it correctly and do all the extra reading and side projects they give you, you'll be learning about all the technologies you would be working with in depth, setting up your own web server and even building a basic web app. I would personally pair that with [Free Code Camp](https://www.freecodecamp.org/learn/) because well, it's free. You'll be able to learn HTML, CSS, JavaScript, SQL, Python, and C# all in one place. Do you need to learn to code? No. Does it help? Yes. Do you need to learn these languages? No. Are there other languages that would be useful? Yes. You'll come across many programming languages like PHP, Java, Ruby etc. The list could go on. Pick something you enjoy learning, or just pick up reading little scraps of code as you go. Another honorable mention is [The Shell Scripting Tutorial](https://www.shellscript.sh/) because you'll likely spend some time in a Unix shell and little scripts can make your life easier.

Practicing your craft is a must. Bug bounty or setting up your own labs are great options, but I must mention [Hack The Box](https://www.hackthebox.com/) and [TryHackMe](https://tryhackme.com) I prefer Hack The Box but both are great. TryHackMe also just released a web app pentesting path, but I've left it off the list until I can actually review it. Grabbing yourself a CVE would also be some resume gold. That's a long topic and will need to wait until you develop some of the basic skills you need, but my friend Tyler Ramsbey talks about that here ["I Found 8 CVEs in 2 Weeks (And You Can Too!)"](https://www.youtube.com/watch?v=2VB4Zd5C8N8).

The pathway I laid out above is just a suggestion for someone caught up in analysis paralysis. The rest of the resources laid out here will be things that I have found useful and you can pick and choose at your own discretion. Another thing to consider is that networking is very helpful for finding gainful employment (people networking not TCP/IP). LinkedIn, Discord, and local meetups/conventions can help in this aspect but it's up to you to play well with others.


## Web app pentesting training Material

### Web app pentesting free courses
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
	- I recommend the bug bounty hunter path for beginners for the structure. PortSwigger is just as good and in some ways better. The BSCP certification may also be the best bang for your buck as a web app resume cert.

### Free API training
- [Postman Academy](https://academy.postman.com/)
- [Postman Student Certification](https://academy.postman.com/path/postman-api-fundamentals-student-expert)
- [APIsec University](https://www.apisecuniversity.com/)

### Web app pentesting affordable paid courses
- [TCM Academy Practical Bug Bounty, Practical Web Hacking, Practical API Hacking](https://academy.tcm-sec.com)
	- Also great material here and you'll find some vulnerabilities covered here that aren't in the bug bounty hunter path. If you do well with video learning these courses are the way.


### Web app pentesting expensive but worth it courses
- [Hack The Box Senior Web Penetration Tester Path](https://academy.hackthebox.com/path/preview/senior-web-penetration-tester)
	- Not recommended as your first course but worth listing here for later.

## Certifications

### Affordable and possibly less resume impact
- [Hack the Box Certified Bug Bounty Hunter](https://academy.hackthebox.com/preview/certifications/htb-certified-bug-bounty-hunter)
- [TCM Security Practical Web Pentest Associate](https://certifications.tcm-sec.com/pwpa/)
- [TCM Security Practical Web Pentest Professional](https://certifications.tcm-sec.com/pwpp/)

### Affordable and possibly more resume impact
- [Burp Suite Certified Practitioner](https://portswigger.net/web-security/certification)

### Expensive and possibly more resume impact 
Courses not listed in training because I think the cheaper courses listed are just as good if not better.
- [OSWA](https://www.offsec.com/courses/web-200/)
- [OSWE](https://www.offsec.com/courses/web-300/)


## Useful sites methodology, tricks, tips, and payloads
You'll see these resources referenced heavily in many of the training courses listed above and for good reason.
- [AppSecExplained](https://appsecexplained.gitbook.io/appsecexplained)
- [Payloads All The Things](https://swisskyrepo.github.io/PayloadsAllTheThings/)
- [HackTricks](https://book.hacktricks.xyz/pentesting-web/web-vulnerabilities-methodology)


## Community
A great way to meet people in the industry, find mentorship, and share resources.
- [Hack Smarter](https://hacksmarter.org/) Free mentoring, great Discord community.
- [PortSwigger Discord](https://discord.gg/portswigger) Technical Burp Suite and App sec help. Community seems to be growing a bit as well.
- [TCM Security Discord](https://discord.gg/tcm) Good community but large Discord.
- Hack the Box and TryHackme have Discords but they are too large and noisy for me. If I need help with Hack the Box I prefer the [forums](https://forum.hackthebox.com/)


## The YouTubes - Active, informational, and minimal click bait
- [Tib3rius](https://www.youtube.com/@Tib3rius) Plenty of web app related live streams.
- [Rana Khalil](https://www.youtube.com/@RanaKhalil101) Great walkthroughs for the PortSwigger material.
- [Tyler Ramsbey](https://www.youtube.com/@TylerRamsbey) Pentesting and Ethical hacking live streams.
- [NahamSec](https://www.youtube.com/@NahamSec) Bug bounty tips.
- [TCM Security](https://www.youtube.com/c/thecybermentor) Ethical hacking streams and videos. Alex puts out some great web app material.


## Reading
List to be updated as I find helpful books and blog posts.
- [Web Application Hackers Handbook](https://www.amazon.com/Web-Application-Hackers-Handbook-Exploiting/dp/1118026470) This and older book but the methodology and explanations of how all components of a web application work are great. If you were doing the Bug Bounty Hunter Path from HTB and PortSwigger you can easily skip this book but it's still worth the mention.
- [Red Team Field Manual](https://www.amazon.com/RTFM-Red-Team-Field-Manual/dp/1075091837/ref=pd_lpo_d_sccl_1/134-0980587-1022640?pd_rd_w=H78kq&content-id=amzn1.sym.4c8c52db-06f8-4e42-8e56-912796f2ea6c&pf_rd_p=4c8c52db-06f8-4e42-8e56-912796f2ea6c&pf_rd_r=TR5DSKBXJ789NW3JNWS4&pd_rd_wg=fD2mg&pd_rd_r=d4e00e87-3da5-4853-9b2b-de69622ab5c6&pd_rd_i=1075091837&psc=1) Not web app but contains enough useful information and just a cool book.
- HTTP headers https://www.darkrelay.com/post/http-security-headers


## Other useful links
- Home Lab and CTF https://benheater.com/
	- Ben's site can be very useful through your entire journey. Explore his material well, do not skip. If you decided on going the route of setting up your own home lab then extra don't skip.
- Burpsuite Pro is great, but the free version has it's limitations. For unthrottled fuzzing and vulnerability scanning OWASP Zap is an amazing free alternative https://www.zaproxy.org/ I've linked this here because while Hack the Box Academy covers ZAP, many other courses don't.
