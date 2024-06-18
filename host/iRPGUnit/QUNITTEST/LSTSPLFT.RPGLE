**FREE
// ==========================================================================
//  iRPGUnit SelfTest - Test LSTSPLF.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  RUCRTRPG  TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  MODULE(&LI/JOBLOG  +
//                      &LI/LSTSPLF +
//                      &LI/PGMMSG  );
//     >>PARM<<  COPTION(*EVENTF *SRCSTMT);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>CMD<<     CMPMOD MODULE(&LI/JOBLOG ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/LSTSPLF) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt NoMain;
/include qinclude,H_SPEC

dcl-f QSYSPRT printer(80) oflind(*in70) usropn;

//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,TESTCASE                  iRPGUnit Test Suite

/include qinclude,LSTSPLF

//  system -- Execute a Command
//     Return value       Meaning
//     ----------------   --------------------------------------
//     0                  the command is successful
//     -1                 for a NULL pointer
//     1                  the command fails
dcl-pr system int(10) extproc('system');
  i_clCommand pointer options(*string) value;
end-pr;

dcl-s EXCP_MSGID char(7) import('_EXCP_MSGID');

//----------------------------------------------------------------------
//   TYPE TEMPLATES
//----------------------------------------------------------------------

dcl-ds userData_t qualified template;
  countDeleted int(10);
  splfNm       char(10);
  usrDta       char(10);
end-ds;

//----------------------------------------------------------------------
//   GLOBAL VARIABLES
//----------------------------------------------------------------------

dcl-ds g_status qualified;
  testCaseStarted timestamp;
end-ds;

//----------------------------------------------------------------------
//   PRIVATE PROTOTYPES
//----------------------------------------------------------------------

dcl-pr setUp extproc('setUp');
end-pr;

dcl-pr tearDown extproc('tearDown');
end-pr;

dcl-pr deleteSplfCallback ind extproc('deleteSplfCallback');
  i_hSplF       pointer       const;
  i_pUserData   pointer       const;
  i_splfNm      char(10)      const;
  i_qJob        likeds(Job_t) const;
  i_splFNbr     int(10)       const;
  i_fileStatus  char(10)      const;
end-pr;

dcl-pr createSpooledFile extproc('createSpooledFile');
  i_name   varchar(10) options(*trim) const;
  i_usrDta varchar(10) options(*trim) const;
end-pr;

dcl-pr waitSecs timestamp extproc('waitSecs');
  i_seconds int(10) const options(*nopass);
end-pr;

dcl-proc setUp export;
  dcl-pi *n;
  end-pi;

  g_status.testCaseStarted = %timestamp();

  createSpooledFile('FILE1': 'FOO');
  createSpooledFile('FILE1': 'BAA');
  createSpooledFile('FILE2': 'FOO');
  createSpooledFile('FILE2': 'BAA');
  createSpooledFile('FILE3': 'FOO-BAA');
  createSpooledFile('FILE3': 'FOO-BAA');
  createSpooledFile('FILE3': 'FOO-BAA');
  createSpooledFile('FILE3': 'FOO');
  createSpooledFile('FILE3': 'BAA');

end-proc;

dcl-proc tearDown export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister   like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);
  dcl-ds qJob     likeds(Job_t);

  clear userData;
  userData.countDeleted = 0;

  clear qJob;
  qJob.name = '*';

  hLister = SplFLister_init(qJob);
  SplFLister_setStartTime(hLister: g_status.testCaseStarted);
  SplFLister_setEndTime(hLister: %timestamp());
  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  clear g_status.testCaseStarted;

end-proc;

//----------------------------------------------------------------------
//   TEST CASES
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//  Test setting status filter.
//----------------------------------------------------------------------
dcl-proc testAddStatus export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister like(hSplFLister_t);
  dcl-ds msgInfo likeds(msgInfo_t);

  hLister = SplFLister_init('*');

  // Already set by SplFLister_init()
  iEqual(1: SplFLister_addStatus(hLister: SL_STS_READY));

  iEqual(2: SplFLister_addStatus(hLister: SL_STS_CLOSED));
  iEqual(3: SplFLister_addStatus(hLister: SL_STS_DEFERRED));
  iEqual(4: SplFLister_addStatus(hLister: SL_STS_SENDING));
  iEqual(5: SplFLister_addStatus(hLister: SL_STS_FINISHED));
  iEqual(6: SplFLister_addStatus(hLister: SL_STS_HELD));
  iEqual(7: SplFLister_addStatus(hLister: SL_STS_MESSAGE));
  iEqual(8: SplFLister_addStatus(hLister: SL_STS_OPEN));
  iEqual(9: SplFLister_addStatus(hLister: SL_STS_PENDING));
  iEqual(10: SplFLister_addStatus(hLister: SL_STS_PRINTER));
  iEqual(11: SplFLister_addStatus(hLister: SL_STS_SAVED));
  iEqual(12: SplFLister_addStatus(hLister: SL_STS_WRITING));

  monitor;
    SplFLister_addStatus(hLister: '*FOO');
    fail('SplFLister_addStatus() should have caused an exception');
  on-error;
    // Exception seen
    msgInfo = getMonitoredMessage(*on);
    aEqual('Invalid status value: *FOO': msgInfo.txt);
  endmon;

end-proc;

//----------------------------------------------------------------------
//  Select spooled files by name and user data.
//----------------------------------------------------------------------
dcl-proc testFile1 export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister   like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);
  dcl-ds qJob     likeds(Job_t);
  dcl-s splfNm varchar(10) inz('FILE1');
  dcl-s usrDta varchar(10) inz('FOO');

  clear userData;
  userData.countDeleted = 0;
  userData.splfNm = splfNm;
  userData.usrDta = usrDta;

  clear qJob;
  qJob.name = '*';

  hLister = SplFLister_init(qJob: splfNm: usrDta);
  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  assert(userData.countDeleted = 1
         : 'Expected to delete 1 file, but was ' +
            %char(userData.countDeleted) + ' files');

end-proc;

//----------------------------------------------------------------------
//  Select spooled files by name.
//----------------------------------------------------------------------
dcl-proc testFile2 export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister   like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);
  dcl-ds qJob     likeds(Job_t);
  dcl-s splfNm varchar(10) inz('FILE2');
  dcl-s usrDta varchar(10) inz('');

  clear userData;
  userData.countDeleted = 0;
  userData.splfNm = splfNm;
  userData.usrDta = usrDta;

  clear qJob;
  qJob.name = '*';

  hLister = SplFLister_init(qJob: splfNm: usrDta);
  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  assert(userData.countDeleted = 2
         : 'Expected to delete 2 files, but was ' +
            %char(userData.countDeleted) + ' files');

end-proc;

//----------------------------------------------------------------------
//  Select spooled files by user data.
//----------------------------------------------------------------------
dcl-proc testFile3 export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister   like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);
  dcl-ds qJob     likeds(Job_t);
  dcl-s splfNm varchar(10) inz('');
  dcl-s usrDta varchar(10) inz('FOO-BAA');

  clear userData;
  userData.countDeleted = 0;
  userData.splfNm = splfNm;
  userData.usrDta = usrDta;

  clear qJob;
  qJob.name = '*';

  hLister = SplFLister_init(qJob: splfNm: usrDta);
  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  assert(userData.countDeleted = 3
         : 'Expected to delete 3 files, but was ' +
            %char(userData.countDeleted) + ' files');

end-proc;

//----------------------------------------------------------------------
//  Select spooled files by creation time.
//----------------------------------------------------------------------
dcl-proc testStartAndEndTime export;
  dcl-pi *n;
  end-pi;

  dcl-s hLister   like(hSplFLister_t);
  dcl-ds userData likeds(userData_t);
  dcl-ds qJob     likeds(Job_t);
  dcl-s startTime timestamp;

  clear qJob;
  qJob.name = '*';

  clear userData;
  userData.countDeleted = 0;
  userData.splfNm = 'DELETE';
  userData.usrDta = 'DELETE-NOW';

  hLister = SplFLister_init(qJob);

  SplFLister_setStartTime(hLister: waitSecs());

  createSpooledFile('DELETE': 'DELETE-NOW');
  createSpooledFile('DELETE': 'DELETE-NOW');
  createSpooledFile('DELETE': 'DELETE-NOW');

  SplFLister_setEndTime(hLister: %timestamp());

  startTime = waitSecs();

  createSpooledFile('LATER': 'DLT-LATER');

  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  assert(userData.countDeleted = 3
         : 'Expected to delete 3 files, but was ' +
            %char(userData.countDeleted) + ' files');

  clear userData;
  userData.countDeleted = 0;
  userData.splfNm = 'LATER';
  userData.usrDta = 'DLT-LATER';

  hLister = SplFLister_init(qJob: 'LATER');
  SplFLister_setStartTime(hLister: startTime);
  SplFLister_list(hLister: %paddr('deleteSplfCallback'): %addr(userData));

  assert(userData.countDeleted = 1
         : 'Expected to delete 1 file, but was ' +
            %char(userData.countDeleted) + ' files');

end-proc;

//----------------------------------------------------------------------
//  Delete spooled file callback.
//----------------------------------------------------------------------
dcl-proc deleteSplfCallback export;
  dcl-pi *n ind;
    i_hSplF       pointer       const;
    i_pUserData   pointer       const;
    i_splfNm      char(10)      const;
    i_qJob        likeds(Job_t) const;
    i_splFNbr     int(10)       const;
    i_fileStatus  char(10)      const;
  end-pi;

  dcl-ds userData likeds(userData_t) based(i_pUserData);

  dcl-s usrDta char(10);

  if (i_pUserData <> *null);
    if (userData.splfNm <> '');
      assert(userData.splfNm = i_splfNm: 'Spooled file names do not match');
    endif;
    if (userData.usrDta <> '');
      usrDta = SplFLister_getUserData(i_hSplf);
      assert(userData.usrDta = usrDta: 'User datas do not match');
    endif;
  endif;

  system('DLTSPLF FILE(' + %trim(i_splfNm) + ') +
            JOB(' + %trim(i_qJob.nbr) + '/' +
                    %trim(i_qJob.user) + '/' +
                    %trim(i_qJob.name) + ') +
            SPLNBR(' + %char(i_splFNbr) + ')');

  if (i_pUserData <> *null);
    userData.countDeleted += 1;
  endif;

  return *on;

end-proc;

//----------------------------------------------------------------------
//  Create spooled file helper procedure.
//----------------------------------------------------------------------
dcl-proc createSpooledFile;
  dcl-pi *n;
    i_name   varchar(10) options(*trim) const;
    i_usrDta varchar(10) options(*trim) const;
  end-pi;

  dcl-ds output qualified;
    data char(80) inz('iRPGUnit SelfTest - Test LSTSPLF.');
  end-ds;

  system('OVRPRTF FILE(QSYSPRT) TOFILE(*FILE) SECURE(*YES) +
            USRDTA(''' + i_usrDta + ''') SPLFNAME(' + i_name + ') OVRSCOPE(*CALLLVL)');

  open QSYSPRT;
  write QSYSPRT output;
  close QSYSPRT;

  system('DLTOVR FILE(QSYSPRT) LVL(*)');

end-proc;

//----------------------------------------------------------------------
//  Wait for the next minute.
//----------------------------------------------------------------------
dcl-proc waitSecs;
  dcl-pi *n timestamp;
    i_seconds int(10) const options(*nopass);
  end-pi;

  if (%parms() >= %parmnum(i_seconds));
    system('DLYJOB DLY(' + %char(i_seconds) + ')');
  else;
    system('DLYJOB DLY(1)');
  endif;

  return %timestamp();

end-proc;
