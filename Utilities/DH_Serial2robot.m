function [robot] = DH_Serial2robot(DH_data) %#codegen
%Transforms a description of the robot provided in DH parameters into the
%robot model.

%It only supports serial configurations.

%--- CODE ---%

%Create Robot structure.
robot=struct();

%Get name
if isfield(DH_data,'name')
    robot.name=DH.data.name;
else
    robot.name='DH robot';
end

%Number of links and joints
robot.n_links=DH_data.n;
robot.n_joints=DH_data.n;
robot.n_q=DH_data.n;

%Create links and joints structures
robot.links=struct();
robot.joints=struct();
robot.base_link=struct();

%Assign origin
robot.origin='DH';

%--- Base link ---%
%Get name
robot.base_link.name='Base';
%Child joint
robot.base_link.child_joint=1;
%Homogeneous transformation
robot.base_link.T=[eye(3),zeros(3,1);zeros(1,3),1];
%Mass and inertia
robot.base_link.mass=DH_data.base.mass;
robot.base_link.inertia=DH_data.base.I;


%--- Iterate through joints and links ---%
for i=1:DH_data.n
    
    %--- Links ---%
    %ID
    robot.links(i).id=i;
    %Get name
    robot.links(i).name=sprintf('L%d',i);
    %Parent and child joints
    robot.links(i).parent_joint=i;
    if i<DH_data.n
        robot.links(i).child_joint=i+1;
    else
        robot.links(i).child_joint=[];
    end
    %Compute Rotation matrix and translation vector from DH parameters
    [R,s] = DH_Rs(DH_data.man(i).DH,0,DH_data.man(i).type);
    %Homogeneous transformation matrix
    if i==DH_data.n
        %Add end-effector's DH parameters
        R_EE=[  cos(DH_data.EE.theta),-sin(DH_data.EE.theta),0;
            sin(DH_data.EE.theta),cos(DH_data.EE.theta),0;
            0,0,1];
        s_EE=[0;0;DH_data.EE.d];
        robot.links(i).T=([R,s;zeros(1,3),1]*[R_EE,s_EE;zeros(1,3),1])/[eye(3),DH_data.man(i).b;zeros(1,3),1];
    else
        robot.links(i).T=[R,s;zeros(1,3),1]/[eye(3),DH_data.man(i).b;zeros(1,3),1];
    end
    %Mass and inertia
    robot.links(i).mass=DH_data.man(i).mass;
    robot.links(i).inertia=DH_data.man(i).I;
    
    %--- Joints ---%
    %ID
    robot.joints(i).id=i;
    %Get name
    robot.joints(i).name=sprintf('J%d',i);
    %Type
    robot.joints(i).type=DH_data.man(i).type;
    %Joint variable ID
    robot.joints(i).q_id=i;
    %Parent and child link
    robot.joints(i).parent_link=i-1;
    robot.joints(i).child_link=i;
    %Axis
    robot.joints(i).axis=[0;0;1];
    %Homogeneous transformation
    if i==1
        robot.joints(i).T=DH_data.base.T_L0_J1;
    else
        %Homogeneous transformation
        robot.joints(i).T=[eye(3),DH_data.man(i-1).b;zeros(1,3),1];
    end
    
end

end