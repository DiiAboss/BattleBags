function geowars_grid(x_pos, y_pos, grid_width = 256, grid_height = room_height, cell_size = 64) constructor 
{
    
    globalvar sz, effect, force_direction, nodes_damping, springs_damping, springs_stiffnes, after_damping;
    
    //Try to experiment with this values
    //Grid behavior depends on the cell size and these parameters
    //Grid can become unstable when they are set improperly
    
    sz = cell_size;         //grid cell size in pixels
    distance = 100;  //how far grid nodes will be affected        (IMPORTANT FOR ALL EFFECTS !!!)
    effect = 0;      //what force effect shoud be used 0-2
    force = 20;      //how strong effect will be                  (IMPORTANT FOR ALL EFFECTS !!!)
    force_direction = irandom(360);  //direction of the force in effect 2
    
    nodes_damping = 0.98; //how fast nodes will lose its speed (0-1) (smaller means faster)
    springs_damping = 0.06 //how fast springs will lose its contraption force (0-1) (smaller means faster)
    springs_stiffnes = 0.18 //stiffnes of the spring (0-1) (larger means that the spring will oscilate faster)
    after_damping = 0.6; //damping used after force effects
    
    
    
    size = cell_size;              //grid cell size
    
    
    nodesx = floor(grid_width / cell_size);    //how many nodes horizontally
    nodesy = floor(grid_height / cell_size);    //how many nodes vertically
    
    grid_xoff = x_pos;          //offset position of the grid in the screen
    grid_yoff = y_pos;
    
    //nodes = array_create(13, array_create(13));
    
    count = 0;
    for(j=0; j<nodesy; j++)
    for(i=0; i<nodesx; i++)  
    {
        nodes[count, 0] = i*cell_size + grid_xoff; //origin pos never used could be used to stabilize grid for certain effects
        nodes[count, 1] = j*cell_size + grid_yoff;
        nodes[count, 2] = 0;
        
        nodes[count, 3] = i*cell_size + grid_xoff; //current pos
        nodes[count, 4] = j*cell_size + grid_yoff;
        nodes[count, 5] = 0;
        
        nodes[count, 6] = 0; //velocity
        nodes[count, 7] = 0;
        nodes[count, 8] = 0;
        
        nodes[count, 9] = 0; //acceleration
        nodes[count, 10] = 0;
        nodes[count, 11] = 0;
        
        nodes[count, 12] = 0.98; //damping
        nodes[count, 13] = 1; //inverse mas smaller value means node is havier. Can be used to create certain areas of the grid easier/harder to move
        if(i==0 || i==nodesx-1 || j==0 || j==nodesy-1) nodes[count, 13] = 0; //inverse mas for border points they can't be moved
        
        count++; 
    }
    
    
    
    static geogrid_update = function(_self, _input)
    {
        var inp_act = _input.ActionKey;
        var _hover_x = mouse_x;
        var _hover_y = mouse_y;
        
        
        
        
        if(inp_act)
        {    
            explode_grid(_hover_x, _hover_y, 64, 8);
        }

        //update all springs between nodes
        count = 0;
        tsize = size * 0.95;
        for(j=0; j<nodesy; j++)
        {
           for(i=0; i<nodesx; i++)  
           {    
               if(i<nodesx-1) 
               {
                    var countp = count+1; 
                            
                    vx = nodes[count, 3] - nodes[countp, 3];
                    vy = nodes[count, 4] - nodes[countp, 4];
                    vz = nodes[count, 5] - nodes[countp, 5];
                    len = point_distance_3d(0, 0, 0, vx, vy, vz);
                            
                    if(len>tsize)
                    {
                        vx = (vx / len) * (len - tsize);
                        vy = (vy / len) * (len - tsize);
                        vz = (vz / len) * (len - tsize);
                        
                        dvx = nodes[countp, 6] - nodes[count, 6];
                        dvy = nodes[countp, 7] - nodes[count, 7];
                        dvz = nodes[countp, 8] - nodes[count, 8];
                        
                        forcex = springs_stiffnes * vx - dvx * springs_damping;
                        forcey = springs_stiffnes * vy - dvy * springs_damping;
                        forcez = springs_stiffnes * vz - dvz * springs_damping;                
                        
                        nodes[count, 9] += nodes[count, 13] * -forcex; 
                        nodes[count, 10] += nodes[count, 13] * -forcey;
                        nodes[count, 11] += nodes[count, 13] * -forcez;
                        
                        nodes[countp, 9] += nodes[countp, 13] * forcex; 
                        nodes[countp, 10] += nodes[countp, 13] * forcey;
                        nodes[countp, 11] += nodes[countp, 13] * forcez;
                    }
               }   
               
               if(j<nodesy-1) 
               {
                    var countp = count+nodesx; 
                    
                    vx = nodes[count, 3] - nodes[countp, 3];
                    vy = nodes[count, 4] - nodes[countp, 4];
                    vz = nodes[count, 5] - nodes[countp, 5];
                    len = point_distance_3d(0, 0, 0, vx, vy, vz);
                    
                    if(len>tsize)
                    {
                        vx = (vx / len) * (len - tsize);
                        vy = (vy / len) * (len - tsize);
                        vz = (vz / len) * (len - tsize);
                        
                        dvx = nodes[countp, 6] - nodes[count, 6];
                        dvy = nodes[countp, 7] - nodes[count, 7];
                        dvz = nodes[countp, 8] - nodes[count, 8];
                        
                        forcex = springs_stiffnes * vx - dvx * springs_damping;
                        forcey = springs_stiffnes * vy - dvy * springs_damping;
                        forcez = springs_stiffnes * vz - dvz * springs_damping;                
                        
                        nodes[count, 9] += nodes[count, 13] * -forcex; 
                        nodes[count, 10] += nodes[count, 13] * -forcey;
                        nodes[count, 11] += nodes[count, 13] * -forcez;
                        
                        nodes[countp, 9] += nodes[countp, 13] * forcex; 
                        nodes[countp, 10] += nodes[countp, 13] * forcey;
                        nodes[countp, 11] += nodes[countp, 13] * forcez;
                    }
               }   
               count++;
           }
        }
        
        
        //update all nodes
        for(i=0; i<array_height_2d(nodes); i++)
        {
           nodes[i, 6] += nodes[i, 9];  //velocity + acceleration
           nodes[i, 7] += nodes[i, 10];
           nodes[i, 8] += nodes[i, 11];
           
           nodes[i, 3] += nodes[i, 6]; //position + velocity
           nodes[i, 4] += nodes[i, 7];
           nodes[i, 5] += nodes[i, 8];
           
           nodes[i, 9] = 0;  //acceleration
           nodes[i, 10] = 0;
           nodes[i, 11] = 0;
           
           if(point_distance_3d(0, 0, 0, nodes[i, 6], nodes[i, 7], nodes[i, 8])<0.000001) 
           {
               nodes[i, 6] = 0; //velocity
               nodes[i, 7] = 0;
               nodes[i, 8] = 0;
           }
           
           nodes[i, 6] *= nodes[i, 12]; //velocity * damping
           nodes[i, 7] *= nodes[i, 12];
           nodes[i, 8] *= nodes[i, 12];
           
           nodes[i, 12] = nodes_damping;
        }
        
    }
    
    function geogrid_draw(_self)
    {
        var alp = draw_get_alpha();
        var col = draw_get_color();
        
        //draw_set_color(c_white);
        draw_set_alpha(0.1);
        
        count = 0;
        
        for(j=0; j<nodesy; j++)
        {
        for(i=0; i<nodesx; i++)  
        {  
            px = nodes[count, 3];
            py = nodes[count, 4];// + _self.global_y_offset;   
            
            //drawing horizontal lines
            if(i<nodesx-1) 
            {
            var countp = count+1;   
            dst = point_distance(px, py, nodes[countp, 3], nodes[countp, 4]);
            draw_set_alpha(0.2 + 0.1 * abs(1-dst/size));
            draw_line(px, py + _self.global_y_offset, nodes[countp, 3], nodes[countp, 4] + _self.global_y_offset);
            
            if(j<nodesy-1)
            {    
                countm = count+nodesx; 
                countpm = countp+nodesx; 
                    
                pmx = 0.5*(px + nodes[countm, 3]);
                pmy = 0.5*(py + nodes[countm, 4]) + _self.global_y_offset;
                pmx2 = 0.5*(nodes[countp, 3] + nodes[countpm, 3]);
                pmy2 = 0.5*(nodes[countp, 4] + nodes[countpm, 4])  + _self.global_y_offset;
                
                draw_line(pmx, pmy, pmx2, pmy2);         
            }
            }   
            
            //drawing vertical lines
            if(j<nodesy-1) 
            {
            var countp = count+nodesx;    
            dst = point_distance(px, py, nodes[countp, 3], nodes[countp, 4]);
            draw_set_alpha(0.1 + 0.1 * abs(1-dst/size));
            draw_line(px, py, nodes[countp, 3], nodes[countp, 4]);
            
            if(i<nodesx-1)
            {    
                countm = count+1; 
                countpm = countp+1; 
        
                pmx = 0.5*(px + nodes[countm, 3]);
                pmy = 0.5*(py + nodes[countm, 4]);// + _self.global_y_offset;
                pmx2 = 0.5*(nodes[countp, 3] + nodes[countpm, 3]);
                pmy2 = 0.5*(nodes[countp, 4] + nodes[countpm, 4]);// + _self.global_y_offset;
                    
                draw_line(pmx, pmy, pmx2, pmy2);          
            }
            }   
            count++;        
        }
        } 
        
        draw_set_alpha(alp);
        draw_set_color(col);
    }
    
}


/// @description direct_force_grid(x, y, distance, force, direction)
/// @param x
/// @param  y
/// @param  distance
/// @param  force
/// @param  direction
function direct_force_grid(argument0, argument1, argument2, argument3, argument4) {
    //script applies force in the given coordinates of the screen with the given force strength, effect distance and direction
    var i, mx = argument0, my = argument1, pomX, pomY, pomZ, dst, distance = argument2, force = argument3, force_direction = argument4;

    for (i = 0; i<array_height_2d(nodes); i++)
    {
    pomX = nodes[i, 3];
    pomY = nodes[i, 4];
    pomZ = nodes[i, 5];
        
    dst = point_distance_3d(mx, my, 0, pomX, pomY, pomZ);

    if(dst<distance)
    {
        forcex = 10*lengthdir_x(force, force_direction) / (10 + dst);
        forcey = 10*lengthdir_y(force, force_direction) / (10 + dst);
        forcez = 0;
    
        nodes[i, 9] += nodes[i, 13] * forcex; 
        nodes[i, 10] += nodes[i, 13] * forcey;
        nodes[i, 11] += nodes[i, 13] * forcez;
    }
    }



}


/// @description explode_grid(x, y, distance, force)

function explode_grid(argument0, argument1, argument2, argument3) {
    //script creates exploding effect in the given coordinates of the screen with the given force and effect distance

    var i, mx = argument0, my = argument1, pomX, pomY, pomZ, dst, distance = argument2, force = argument3;
    
    for (i = 0; i<array_height_2d(nodes); i++)
    {
    pomX = nodes[i, 3];
    pomY = nodes[i, 4];
    pomZ = nodes[i, 5];
        
    dst = point_distance_3d(mx, my, 0, pomX, pomY, pomZ);

    if(dst<distance)
    {
        //calculating forces acting on a given node in x,y,z directions
        forcex = 100 * force * (pomX - mx) / (10000 + dst);
        forcey = 100 * force * (pomY - my) / (10000 + dst);
        forcez = 100 * force * (pomZ - 0 ) / (10000 + dst);
    
        //applying forces to the node
        nodes[i, 9]  += nodes[i, 13] * forcex; 
        nodes[i, 10] += nodes[i, 13] * forcey;
        nodes[i, 11] += nodes[i, 13] * forcez;
    
        nodes[i, 12] = after_damping;
    }
    }







}


/// @description implode_grid(x, y, distance, force)
/// @param x
/// @param  y
/// @param  distance
/// @param  force
function implode_grid(argument0, argument1, argument2, argument3) {
    //script creates imploding effect in the given coordinates of the screen with the given force and effect distance
    var i, mx = argument0, my = argument1, pomX, pomY, pomZ, dst, distance = argument2, force = argument3;

    for (i = 0; i<array_height_2d(nodes); i++)
    {
    pomX = nodes[i, 3];
    pomY = nodes[i, 4];
    pomZ = nodes[i, 5];
        
    dst = point_distance_3d(mx, my, 0, pomX, pomY, pomZ);

    if(dst<distance)
    {
        //calculating forces acting on a given node in x,y,z directions
        forcex = 10 * force * (mx - pomX) / (1000 + dst);
        forcey = 10 * force * (my - pomY) / (1000 + dst);
        forcez = 10 * force * (0  - pomZ) / (1000 + dst);
    
        //applying forces to the node
        nodes[i, 9] += nodes[i, 13] * forcex; 
        nodes[i, 10] += nodes[i, 13] * forcey;
        nodes[i, 11] += nodes[i, 13] * forcez;
    
        nodes[i, 12] = after_damping;
    }
    }



}



/// @description push_down_grid(x, y, distance, force)
/// @param x
/// @param  y
/// @param  distance
/// @param  force
function push_down_grid(argument0, argument1, argument2, argument3) {
    //script creates pushing effect in the given coordinates of the screen with the given force and effect distance

    var i, mx = argument0, my = argument1, pomX, pomY, pomZ, dst, distance = argument2, force = argument3;


    for (i = 0; i<array_height_2d(nodes); i++)
    {
    pomX = nodes[i, 3];
    pomY = nodes[i, 4];
        
    dst = point_distance(mx, my, pomX, pomY);
    
    if(abs(mx-pomX)<distance*0.8 && abs(my-pomY)<distance*0.8)     
        if(nodes[i, 13]==1)
        {
        nodes[i, 3] += (mx-nodes[i, 3]) * (1-dst/distance)*(force/90);
        nodes[i, 4] += (my-nodes[i, 4]) * (1-dst/distance)*(force/90);  
        }  
    }



}
