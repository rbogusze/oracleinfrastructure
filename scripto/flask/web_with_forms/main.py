# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START gae_python38_app]
from flask import Flask
from google.cloud import storage
import os
from pandas import DataFrame
import pandas as pd
from json2html import *
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired
from flask import render_template
from forms import LoginForm
from config import Config

class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


#print(os.environ['GOOGLE_APPLICATION_CREDENTIALS'])
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="/home/remik/_poufne/keys/gce/remi-project-210613-9a91ccf0f8a1.json"
bucket_name = "remi-project-210613.appspot.com"


def read_from_gs(file_name):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    return blob.download_as_string()

def write_to_gs(file_name, content):
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)
    blob.upload_from_string(str(content))





# If `entrypoint` is not defined in app.yaml, App Engine will look for an app
# called `app` in `main.py`.
app = Flask(__name__)
app.config.from_object(Config)


@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    #data = {'Product': ['Desktop Computer','Tablet','iPhone','Laptop'],
    #      'Price': [700,250,800,1200]
    #       }
    #df = DataFrame(data, columns= ['Product', 'Price'])
    #df_str = df.to_json()
    #write_to_gs('zebra.txt',df_str)

    df = pd.read_json(read_from_gs('zebra.txt'))
    df_str = df.to_json()

    #return str(df_str)
    #return json2html.convert(json = df_str)
    user = {'username': 'Remi'}
    return render_template('index.html', title='Home', user=user)


@app.route('/login')
def login():
    form = LoginForm()
    return render_template('login.html', title='Sign In', form=form)


if __name__ == '__main__':
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. This
    # can be configured by adding an `entrypoint` to app.yaml.
    app.run(host='127.0.0.1', port=8080, debug=True)
# [END gae_python38_app]
