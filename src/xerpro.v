// Copyright (c) 2022 jeffrey -at- ieee.org. All rights reserved.
// Use of this source code (/program) is governed by an MIT license,
// that can be found in the LICENSE file. Do not remove this header.
import os
import flag

fn main()
{
	mut fp := flag.new_flag_parser(os.args)
    fp.application('xerpro')
	
    fp.version('v2022.06.13\nCopyright (c) 2022 jeffrey -at- ieee.org. All rights \
	reserved.\nUse of this source code (/program) is governed by an MIT \
	license,\nthat can be found in the LICENSE file.')

    fp.description('\nProduces a SWI-Prolog script for schedule optimization.\n\
	This software will -NOT- make any changes to your XER files.')

    fp.skip_executable()

    mut xer_arg := fp.string('xer', `f`, "", 
								'specify the XER for analysis')
										
	additional_args := fp.finalize() or {
        eprintln(err)
        println(fp.usage())
        return
    }

	additional_args.join_lines()
	
	if xer_arg.len==0
	{
		eprintln("[ERROR] You must specify an XER file for analysis.\nSee usage below.\n")
		println(fp.usage())
		exit(0)
		return
	}		

	xer_base_name := xer_arg.all_before_last(".xer")

	lines := os.read_lines(xer_arg) or {panic(err)}
		
	mut line_index := 0

	mut taskpred_arr := []Taskpred{}
	mut task_arr := []Task{}

	for line in lines
	{	
		line_index++
		if compare_strings(line,"%T\tTASKPRED") == 0
		{
			line_index++ // Advance passed header...

			for i:=line_index; i<lines.len; i++
			{
				if lines[i].starts_with("%T")
				{
					break
				}

				mut delimited_row := lines[i].split("\t")

				mut a_taskpred := Taskpred{}

				a_taskpred.task_pred_id = delimited_row[1]
				a_taskpred.task_id = delimited_row[2]
				a_taskpred.pred_task_id = delimited_row[3]
				a_taskpred.proj_id = delimited_row[4]
				a_taskpred.pred_proj_id = delimited_row[5]
				a_taskpred.pred_type = delimited_row[6]
				a_taskpred.lag_hr_cnt = delimited_row[7]

				taskpred_arr << a_taskpred
			
			}
		}

		if compare_strings(line,"%T\tTASK") == 0
		{
			line_index++ // Advance passed header...

			for i:=line_index; i<lines.len; i++
			{

				if lines[i].starts_with("%T")
				{
					break
				}

				mut delimited_row := lines[i].split("\t")

				mut a_task := Task{}

				a_task.task_id = delimited_row[1]
				a_task.task_code = delimited_row[14]
				a_task.task_name = delimited_row[15]
				
				task_arr <<	a_task
			}
		}	
	}

	mut prolog_out := os.create("${xer_base_name}.pl") or {panic(err)}

	prolog_out.writeln("% Dynamic facts for relations,") or {panic(err)}
	prolog_out.writeln("% as they may not all exist in a XER.") or {panic(err)}
	prolog_out.writeln(":- dynamic(rel_fs/2).") or {panic(err)}
	prolog_out.writeln(":- dynamic(rel_sf/2).") or {panic(err)}
	prolog_out.writeln(":- dynamic(rel_ss/2).") or {panic(err)}
	prolog_out.writeln(":- dynamic(rel_ff/2).") or {panic(err)}

	prolog_out.writeln("\n% Activity relationships,") or {panic(err)}
	prolog_out.writeln("% Sorted by relationship type.") or {panic(err)}

	mut rel_arr := []string{}

	for elem in taskpred_arr {
		
		mut rel_type := ""
		if compare_strings(elem.pred_type,"PR_FS")==0 {
			rel_type = "fs"
		} else if compare_strings(elem.pred_type,"PR_SS")==0 {
			rel_type = "ss"
		} else if compare_strings(elem.pred_type,"PR_SF")==0 {
			rel_type = "sf" 
		} else {
			rel_type = "ff"
		}

		rel_arr << "rel_${rel_type}(${elem.pred_task_id},${elem.task_id})."

		
	}

	rel_arr.sort()

	for elem in rel_arr
	{
		prolog_out.writeln(elem) or {panic(err)}
	}

	prolog_out.writeln("\n% Activity ID and Names") or {panic(err)}
	for elem in task_arr {
		
		prolog_out.writeln("activity(${elem.task_id},\"${elem.task_code}\",\"${elem.task_name}\").") or {panic(err)}
	}

	prolog_out.close()

}

struct Task {
	mut:
		task_id string
		task_code string
		task_name string
}

struct Taskpred {
	mut:
		task_pred_id string
		task_id string
		pred_task_id string
		proj_id string
		pred_proj_id string
		pred_type string
		lag_hr_cnt string
}
