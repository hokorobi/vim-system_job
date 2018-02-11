scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#system_job#new()
let s:Job = s:V.import('System.Job')

function! s:_on_stdout(data) abort dict
  let self.stdout[-1] .= a:data[0]
  call extend(self.stdout, a:data[1:])
endfunction

function! s:_on_stderr(data) abort dict
  let self.stderr[-1] .= a:data[0]
  call extend(self.stderr, a:data[1:])
endfunction

function! s:jobstartwrap(list) abort
  if type(a:list[0]) == v:t_list
    let args = a:list[0]
  else
    let args = a:list
  endif

  let job = s:Job.start(args, {
        \ 'stdout': [''],
        \ 'stderr': [''],
        \ 'on_stdout': function('s:_on_stdout'),
        \ 'on_stderr': function('s:_on_stderr'),
        \})
  let exit_status = job.wait()
  return {
        \ 'exit_status': exit_status,
        \ 'stdout': job.stdout,
        \ 'stderr': job.stderr,
        \}
endfunction

function! system_job#systemlist(...) abort
  let job = s:jobstartwrap(a:000)
  if job.exit_status
    return job.stderr
  else
    return job.stdout
  endif
endfunction

function! system_job#system(...) abort
  let job = s:jobstartwrap(a:000)
  let lines = ''
  if job.exit_status
    for line in job.stderr
      let lines .= line . "\n"
    endfor
  else
    for line in job.stdout
      let lines .= line . "\n"
    endfor
  endif
  return lines
endfunction

