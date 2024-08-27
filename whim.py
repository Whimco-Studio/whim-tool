import os
import shutil
import filecmp
import click

@click.group()
def cli():
    pass

@cli.command()
@click.option('--name', prompt='What is the name of this project?', help='Name of the project')
@click.option('--init-interface', is_flag=True, prompt='Would you like to initialize the Interface setup?', help='Initialize Interface setup')
@click.option('--selene', is_flag=True, prompt='Would you like to set up Selene?', help='Set up Selene for static analysis')
@click.option('--default-project-json', is_flag=True, prompt='Would you like to create a default.project.json file?', help='Create a default.project.json file')
def init(name, init_interface, selene, default_project_json):
    click.echo(f"Initializing project: {name}")
    
    project_path = os.getcwd()
    click.echo(f"Using current directory: {project_path}")
    
    create_project_files(project_path)

    if init_interface:
        copy_interface_templates(project_path)

    if selene:
        click.echo("Setting up Selene...")
        # Add Selene setup logic here

    if default_project_json:
        click.echo("Creating default.project.json file...")
        create_default_project_json(project_path)

    click.echo("Initialization complete!")

@cli.command()
def update():
    """Update project files to match the latest template."""
    project_path = os.getcwd()
    click.echo(f"Updating project in current directory: {project_path}")
    
    update_project_files(project_path)
    update_interface_templates(project_path)
    
    click.echo("Update complete!")

def create_project_files(project_path):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    template_path = os.path.join(script_dir, 'templates', 'project')
    
    copy_files(template_path, project_path)
    click.echo(f"Copied project templates to: {project_path}")

def copy_interface_templates(project_path):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    template_path = os.path.join(script_dir, 'templates', 'Interface')
    
    copy_files(template_path, project_path)
    click.echo(f"Copied Interface templates to: {project_path}")

def update_project_files(project_path):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    template_path = os.path.join(script_dir, 'templates', 'project')
    
    copy_files(template_path, project_path, update=True)

def update_interface_templates(project_path):
    script_dir = os.path.dirname(os.path.realpath(__file__))
    template_path = os.path.join(script_dir, 'templates', 'Interface')
    
    copy_files(template_path, project_path, update=True)

def copy_files(src_dir, dest_dir, update=False):
    for item in os.listdir(src_dir):
        s = os.path.join(src_dir, item)
        d = os.path.join(dest_dir, item)
        
        if os.path.isdir(s):
            if not os.path.exists(d):
                shutil.copytree(s, d)
                click.echo(f"Copied directory: {d}")
            elif update:
                copy_files(s, d, update=True)
        else:
            if not os.path.exists(d) or (update and not filecmp.cmp(s, d, shallow=False)):
                shutil.copy2(s, d)
                click.echo(f"Copied file: {d}")

def create_default_project_json(project_path):
    default_project_json_path = os.path.join(project_path, 'default.project.json')
    with open(default_project_json_path, 'w') as file:
        file.write('{\n  "name": "default",\n  "version": "1.0.0"\n}')
    click.echo(f"Created file: {default_project_json_path}")

if __name__ == '__main__':
    cli()
