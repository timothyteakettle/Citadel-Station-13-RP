
var/const/ENGSEC			=(1<<0)

var/const/CAPTAIN			=(1<<0)
var/const/HOS				=(1<<1)
var/const/WARDEN			=(1<<2)
var/const/DETECTIVE			=(1<<3)
var/const/OFFICER			=(1<<4)
var/const/CHIEF				=(1<<5)
var/const/ENGINEER			=(1<<6)
var/const/ATMOSTECH			=(1<<7)
var/const/AI				=(1<<8)
var/const/CYBORG			=(1<<9)
var/const/CLOWN				=(1<<13)
var/const/MIME				=(1<<14)
var/const/INTERN			=(1<<15)
var/const/SENIOR_ENGINEER	=(1<<16)
var/const/Blueshield		=(1<<17)

var/const/MEDSCI			=(1<<1)

var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/CHEMIST			=(1<<2)
var/const/CMO				=(1<<3)
var/const/DOCTOR			=(1<<4)
var/const/GENETICIST		=(1<<5)
var/const/VIROLOGIST		=(1<<6)
var/const/PSYCHIATRIST		=(1<<7)
var/const/ROBOTICIST		=(1<<8)
var/const/XENOBIOLOGIST		=(1<<9)
var/const/PARAMEDIC			=(1<<10)
var/const/PATHFINDER 		=(1<<11)
var/const/EXPLORER 			=(1<<12)
var/const/SAR 				=(1<<13)
var/const/XENOBOTANIST		=(1<<14)
var/const/HEAD_NURSE		=(1<<15)
var/const/SENIOR_RESEARCHER	=(1<<16)

var/const/CIVILIAN			=(1<<2)

var/const/HOP				=(1<<0)
var/const/BARTENDER			=(1<<1)
var/const/BOTANIST			=(1<<2)
var/const/CHEF				=(1<<3)
var/const/JANITOR			=(1<<4)
var/const/LIBRARIAN			=(1<<5)
var/const/QUARTERMASTER		=(1<<6)
var/const/CARGOTECH			=(1<<7)
var/const/MINER				=(1<<8)
var/const/LAWYER			=(1<<9)
var/const/CHAPLAIN			=(1<<10)
var/const/ASSISTANT			=(1<<11)
var/const/BRIDGE			=(1<<12)
var/const/PILOT 			=(1<<13)
var/const/ENTERTAINER		=(1<<14)
var/const/TRADER			=(1<<15)
var/const/OUTSIDER			=(1<<16)


/proc/guest_jobbans(job)
	return ( (job in SSjob.get_job_titles_in_department(DEPARTMENT_COMMAND)) || (job in SSjob.get_job_titles_in_department(DEPARTMENT_SYNTHETIC)) || (job in SSjob.get_job_titles_in_department(DEPARTMENT_SECURITY)) )

/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/role/job)

	for(var/A in all_jobs)
		var/datum/role/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/role/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles
