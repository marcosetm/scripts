/*
guardian table
- foreign key in accounts.guardian_id - on delete restrict

accout table
- removed record that is linked to guardian_id

guardian id as foreign key in
- account.guardian_id
- student_guardian.guardian_id
- student_monitor_review.guardian_id
- message_recipient.to_guardian_id
- ec_assessment_window_response.guardian_id
*/

select count(*) from account where namespace = 'ps' and guardian_id in (select id from guardian);
select count(*) from student_monitor_review where guardian_id in (select id from guardian);
select count(*) from message_recipient where to_guardian_id in (select id from guardian);
select count(*) from ec_assessment_window_response where guardian_id in (select id from guardian);
select count(*) from student_guardian;
select count(*) from guardian;

-- actual statements executed:
begin;
delete from account where namespace = 'ps' and guardian_id in (select id from guardian);
delete from student_guardian where guardian_id in (select id from guardian);
delete from guardian where upload_id is not null;
commit;

-- scratchpad
begin;
delete from account where namespace = 'ps' and guardian_id in (select id from guardian);
delete from student_monitor_review guardian_id in (select id from guardian);
delete from message_recipient where to_guardian_id in (select id from guardian);
delete from ec_assessment_window_response where guardian_id in (select id from guardian);
delete from student_guardian;
delete from guardian;
rollback;
