print 'Enter the path to local Github Repository'."\n".'(eg: C:\Users\nksh\Documents\GitHub):'."\n";
chomp($gitdir=<STDIN>);
#===============================================================================================================
# Change to specified local GitHub repository which has all local repository
#===============================================================================================================
chdir($gitdir) or die "Directory: \"$gitdir\" does not exist.\n";									

#===============================================================================================================
# List all files/repositories
#================================================================================================================	
@arr=`dir /b`;		
#================================================================================================================
# For each of the listed directories
#================================================================================================================
foreach $sub_directory(@arr)
{																									
chomp($sub_directory);
print "\n\n#####################################################################\n";
print "####    		 REPOSITORY $sub_directory   	  		 ####\n";
print "#####################################################################\n";

$newdir=join('\\',$gitdir,$sub_directory);
print "\nWORK TREE STATUS:\n";	

#=================================================================================================================
# Move into each repository to check the status
#=================================================================================================================
chdir ($newdir) or die "Directory $newdir does not exist\n";										

#=================================================================================================================
# Execute command "git status --porcelain" to get status in an easy-to-parse format for scripts.
# The command gives short output. That is the output is not verbose
# Array @log will contain the output of the command
#=================================================================================================================

@log=`git status --porcelain`;		
$length	=@log;

#=================================================================================================================
# If the length of the array is zero then give a verbose status using command "git status -v"
#=================================================================================================================
if ($length==0)
{
system('git status -v');	
next;
}		

#=================================================================================================================
# For each entry in the array @log, check the status code of the listed files and print the corresponding status
# the command prints the status of each path as 
# XY PATH1 -> PATH2
#where PATH1 is the path in the HEAD, and the " -> PATH2" part is shown only when PATH1 corresponds to a
# different path in the index/worktree (i.e. the file is renamed). The XY is a two-letter status code.
#=================================================================================================================
foreach (@log)
{
#@path=split(/\-\>/,$_)
print ;
if ($_=~/([([A-Za-z0-9\.\_\-]+)[ +\-\> +]?([A-Za-z0-9\.\_\-]+)?$/)
{
print "inside if";
$path1=$1;
$path2=$2;
print "path1= $path1\npath2=$path2\n";

}
next;
if ($_=~/^ [MD]/)									
{
print "File $path1 has NOT been UPDATED\n"																		
}elsif ($_=~/^M[MD]/)
{
print "File $path1 has been UPDATED in INDEX\n";																							# Add commits of each user
}elsif ($_=~/^A[MD]/)
{
print "File $path1 has been ADDED to INDEX\n";																							# Add commits of each user
}elsif ($_=~/^D[MD]/)
{
print "File $path1 has been DELETED from INDEX\n";																							# Add commits of each user
}elsif ($_=~/^R[MD]/)
{
print "File $path1 has been RENAMED in INDEX\n";																							# Add commits of each user
}elsif ($_=~/^C[MD]/)
{
print "File $path1 has been COPIED in INDEX\n";																							# Add commits of each user
}elsif ($_=~/^[MARC] /)
{
print "INDEX AND WORKTREE of file $path1 MATCHES\n";																							# Add commits of each user
}elsif ($_=~/^[ MARC]M/)
{
print "WORKTREE of the file $path1 has been CHANGED since index\n";																							# Add commits of each user
}elsif ($_=~/^[ MARC]D/)
{
print " The file $path1 has been DELETED in WORKTREE\n";																							# Add commits of each user
}elsif ($_=~/^DD/)
{
print "File $path1 and $path2 is UNMERGED AND BOTH  DELETED\n";																							# Add commits of each user
}elsif ($_=~/^AU/)
{
print "File $path1 is UNMERGED AND ADDED BY US\n";																							# Add commits of each user
}elsif ($_=~/^UD/)
{
print "File $path1 is UNMERGED AND DELETED BY THEM\n";																							# Add commits of each user
}elsif ($_=~/^UA/)
{
print "File $path1 is UNMERGED AND ADDED BY THEM\n";																							# Add commits of each user
}elsif ($_=~/^DU/)
{
print "File $path1 is UNMERGED AND DELETED BY US\n";																							# Add commits of each user
}elsif ($_=~/^AA/)
{
print "File $path1 is UNMERGED, both ADDED\n";																							# Add commits of each user
}elsif ($_=~/^AA/)
{
print "File $path1 and $path2 is UNMERGED, both ADDED\n";																							# Add commits of each user
}elsif ($_=~/^UU/)
{
print "File $path1 is UNMERGED, both MODIFIED\n";																							# Add commits of each user
}elsif ($_=~/^\?\?/)
{
print "File $path1 is UNTRACKED\n";																							# Add commits of each user
}elsif ($_=~/^!!/)
{
print "File $path1 and $path2 is UNMERGED, both ADDED\n";																							# Add commits of each user
}

}
system('cd..');
}
