-- SPDX-License-Identifier: Apache-2.0
-- Licensed to the Ed-Fi Alliance under one or more agreements.
-- The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
-- See the LICENSE and NOTICES files in the project root for more information.

SELECT ssa.SchoolId as [School ID], 
	   sta.StaffUniqueId as [Staff ID], 
	   sta.LastSurname as [teacher name],
	   sec.ClassroomIdentificationCode as [Room number],
	   case when gld.CodeValue = 'Kindergarten' then '0'
			when gld.CodeValue = 'First grade' then '1'
			when gld.CodeValue = 'Second grade' then '2'
			when gld.CodeValue = 'Third grade' then '3'
			when gld.CodeValue = 'Fourth grade' then '4'
			when gld.CodeValue = 'Fifth grade' then '5'
       end as [grade],
	   case when pt.CodeValue = 'Special Education' then 'SDC'
		    when pt.CodeValue is NULL then ''
	   end   as [sdc],
	   case when ssa.ClassPeriodName = '1 MTWTF' then 'AL' else ' ' end as [Period ID] ,
	   stu.StudentUniqueId as [ID]
FROM edfi.Staff sta
INNER JOIN edfi.StaffSectionAssociation ssa ON sta.StaffUSI = ssa.StaffUSI --and ssa.StaffUsi not in (1612,544)
INNER JOIN edfi.Descriptor classPos ON ssa.ClassroomPositionDescriptorId = classPos.DescriptorId
INNER JOIN edfi.Section sec ON ssa.SchoolId = sec.SchoolId 
							   and ssa.ClassPeriodName = sec.ClassPeriodName
							   and ssa.ClassroomIdentificationCode = sec.ClassroomIdentificationCode
							   and ssa.LocalCourseCode = sec.LocalCourseCode
							   and ssa.TermDescriptorId = sec.TermDescriptorId
							   and ssa.UniqueSectionCode = sec.UniqueSectionCode
							   and ssa.SequenceOfCourse = sec.SequenceOfCourse
							   and ssa.SchoolYear = sec.SchoolYear
							   --and sec.SchoolYear = 2020
INNER JOIN edfi.StudentSectionAssociation stusa ON sec.SchoolId = stusa.SchoolId 
												   and sec.ClassPeriodName = stusa.ClassPeriodName
												   and sec.ClassroomIdentificationCode = stusa.ClassroomIdentificationCode
												   and sec.LocalCourseCode = stusa.LocalCourseCode
												   and sec.TermDescriptorId = stusa.TermDescriptorId
												   and sec.SchoolYear = stusa.SchoolYear
												   and sec.UniqueSectionCode = stusa.UniqueSectionCode
												   and sec.SequenceOfCourse = stusa.SequenceOfCourse
												   --and stusa.BeginDate < GETDATE() and stusa.EndDate > GETDATE()
INNER JOIN edfi.Student stu ON stusa.StudentUSI = stu.StudentUSI
INNER JOIN edfi.StudentSchoolAssociation stusch ON stusa.SchoolId = stusch.SchoolId 
												   and stusa.StudentUSI = stusch.StudentUSI 
												   and stusch.ExitWithdrawDate is null
												   --and stusch.SchoolYear = 2020
INNER JOIN edfi.Descriptor gld ON stusch.EntryGradeLevelDescriptorId = gld.DescriptorId
LEFT JOIN edfi.StudentProgramAssociation spa ON stu.StudentUSI = spa.StudentUSI and spa.ProgramName in ('Special Education')
LEFT JOIN edfi.ProgramType pt on spa.ProgramTypeId = pt.ProgramTypeId and pt.CodeValue in ('Special Education')
--where ssa.SchoolId in (12,13,16,18,19,20,21,23,24,25,26,27,28,91)
--      and ssa.ClassPeriodName like '1%'
--     and gld.CodeValue <> 'Transitional Kindergarten'
order by ssa.SchoolId,stu.StudentUniqueId  -- staffusi, grade  desc
