SELECT
       s.StudentUniqueId,
	   --s.StudentUSI,
       sic.IdentificationCode as StateId, 
       sex.ShortDescription SexType, 
	   (CASE 
			WHEN s.HispanicLatinoEthnicity=1 then 'Hispanic'
			ELSE 'Non Hispanic'
	    END) Ethnicity,
	  	srm.t1 AS 'American Indian - Alaskan Native', srm.t2 AS 'Asian', srm.t3 AS'Black - African American', srm.t4 AS 'Choose Not to Respond',
	    srm.t5 AS 'Native Hawaiian - Pacific Islander', srm.t6 AS 'Other', srm.t7 AS 'White',
	    lepd.CodeValue as LimitedEnglishProficiency,
	    food.ShortDescription FreeAndReducedLunch,
	    studentprograms.Migrant,
        studentprograms.Homeless,
	    studentprograms.Foster
FROM edfi.Student s
LEFT JOIN edfi.Descriptor food on s.SchoolFoodServicesEligibilityDescriptorId = food.DescriptorId
INNER JOIN edfi.SexType sex on s.SexTypeId = sex.SexTypeId
LEFT JOIN edfi.StudentIdentificationCode sic ON s.StudentUSI = sic.StudentUSI and AssigningOrganizationIdentificationCode = 'State'
LEFT JOIN edfi.Descriptor lepd on s.LimitedEnglishProficiencyDescriptorId = lepd.DescriptorId
LEFT JOIN (SELECT spa.StudentUSI, mspa.ProgramName AS 'Migrant', hspa.ProgramName AS 'Homeless', fspa.ProgramName AS 'Foster' FROM edfi.StudentProgramAssociation AS spa 
	 LEFT JOIN edfi.StudentProgramAssociation AS mspa ON spa.StudentUSI=mspa.StudentUSI AND mspa.EndDate IS NULL AND mspa.ProgramName like 'Migrant%'
	 LEFT JOIN edfi.StudentProgramAssociation AS hspa ON spa.StudentUSI=hspa.StudentUSI AND hspa.ProgramName like '%Homeless%' AND hspa.begindate > '2019-08-14'
	 LEFT JOIN edfi.StudentProgramAssociation AS fspa ON spa.StudentUSI=fspa.StudentUSI AND fspa.EndDate is null AND fspa.ProgramName like '%Foster%'
	 ) AS studentprograms ON s.StudentUSI=studentprograms.StudentUSI
LEFT JOIN (SELECT sr.StudentUSI,sr1.RaceTypeId AS t1,sr2.RaceTypeId AS t2,sr3.RaceTypeId AS t3,sr4.RaceTypeId AS t4,sr5.RaceTypeId AS t5,sr6.RaceTypeId AS t6,sr7.RaceTypeId AS t7
   FROM edfi.StudentRace sr 
	LEFT JOIN edfi.StudentRace sr1 ON sr.StudentUSI = sr1.StudentUsi and sr1.RaceTypeId = 1 --'American Indian - Alaskan Native'
	LEFT JOIN edfi.StudentRace sr2 ON sr.StudentUSI = sr2.StudentUsi and sr2.RaceTypeId = 2 --'Asian'
	LEFT JOIN edfi.StudentRace sr3 ON sr.StudentUSI = sr3.StudentUsi and sr3.RaceTypeId = 3 --'Black - African American'
	LEFT JOIN edfi.StudentRace sr4 ON sr.StudentUSI = sr4.StudentUsi and sr4.RaceTypeId = 4 --'Choose Not to Respond'
	LEFT JOIN edfi.StudentRace sr5 ON sr.StudentUSI = sr5.StudentUsi and sr5.RaceTypeId = 5 --'Native Hawaiian - Pacific Islander'
	LEFT JOIN edfi.StudentRace sr6 ON sr.StudentUSI = sr6.StudentUsi and sr6.RaceTypeId = 6 --'Other'
	LEFT JOIN edfi.StudentRace sr7 ON sr.StudentUSI = sr7.StudentUsi and sr7.RaceTypeId = 7 --'White'
 ) AS srm ON s.StudentUSI=srm.StudentUSI
