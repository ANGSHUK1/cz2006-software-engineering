import sys
from os import path, getcwd
sys.path.append(getcwd())

import unittest 

from exceptions import ErrorWithCode

from models import db
from run_test import create_app
app = create_app()
app.app_context().push()
db.init_app(app)

from models import User
from operations.user_operations import \
    encrypt, authenticate, initialize_user, \
    user_read_operation, user_create_operation, user_update_operation, \
    user_update_password_operation, auth_operation


class Test_users_operations(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        print("\n\n{}: starting test...".format(path.basename(__file__)))

    def setUp(self):
        db.session.remove()
        db.drop_all()
        db.create_all()

        u = initialize_user('johndoe', 'password', 'John Doe')
        db.session.add(u)
        db.session.commit()
    

    def test_encryption(self):

        plaintext_password = 'password'
        encrypted_password = encrypt(plaintext_password)
        self.assertTrue(authenticate(plaintext_password, encrypted_password))
        self.assertFalse(authenticate('wrong_password', encrypted_password))


    def test_user_read_operation(self):

        with self.assertRaises(ErrorWithCode):
            user_read_operation(col='username', value='johndoe1')
            user_read_operation(col='name', value='John Doe Tan')

        res = user_read_operation(col='username', value='johndoe')
        self.assertIsNotNone(res)
        self.assertEqual(type(res), User)
        self.assertEqual(res.name, 'John Doe')

        res = user_read_operation(col='id', value=1)
        self.assertIsNotNone(res)
        self.assertEqual(type(res), User)
        self.assertEqual(res.name, 'John Doe')
    
    
    def test_user_create_operation(self):

        with self.assertRaises(ErrorWithCode):
            user_create_operation('johndoe', 'password', 'John Doe')

        self.assertEqual(user_create_operation('johndoe1', 'password', 'John Doe').id, 2)
        
    
    def test_user_update_operation(self):
        
        with self.assertRaises(ErrorWithCode):
            user_update_operation('johndoe1', 'John Doe', 1, 2, 3)

        self.assertIsNotNone(user_update_operation('johndoe', 'John Doe Tan', 1, 2, 3))
        self.assertEqual(user_update_operation('johndoe', 'John Doe Tan', 1, 2, 3).name, 'John Doe Tan')

        self.assertIsNotNone(user_update_operation('johndoe', 'John Doe Tan', None, None, None))
        self.assertEqual(user_update_operation('johndoe', 'John Doe Tan', None, None, None).name, 'John Doe Tan')

        self.assertIsNotNone(user_update_operation('johndoe', None, 1, None, None))
        self.assertEqual(user_update_operation('johndoe', None, 1, None, None).age, 1)

        self.assertIsNotNone(user_update_operation('johndoe', None, None, 2, None))
        self.assertEqual(user_update_operation('johndoe', None, None, 2, None).height, 2)

        self.assertIsNotNone(user_update_operation('johndoe', None, None, None, 3))
        self.assertEqual(user_update_operation('johndoe', None, None, None, 3).weight, 3)


    def test_user_update_password_operation(self):

        with self.assertRaises(ErrorWithCode):
            user_update_password_operation('johndoe1', 'password_wrong', 'password_new')
            user_update_password_operation('johndoe1', 'password', 'password_new')
    
        self.assertIsNotNone(user_update_password_operation('johndoe', 'password', 'password_new'))

        user = User.query.filter_by(username='johndoe').first()
        self.assertTrue(authenticate('password_new', user.encrypted_password))

    
    def test_auth_operation(self):

        self.assertRaises(ErrorWithCode, auth_operation, 'johndoe1', 'password')
        self.assertRaises(ErrorWithCode, auth_operation, 'johndoe', 'password1')
        self.assertTrue(auth_operation('johndoe', 'password'))


if __name__ == '__main__':
    unittest.main()
    