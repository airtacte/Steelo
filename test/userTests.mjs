import * as chai from 'chai';
import chaiHttp from 'chai-http';
import sinon from 'sinon';
import admin from 'firebase-admin';
import firebaseAdminMock from 'firebase-admin-mock';
import app from '../server/server.js'; // Adjust the path as per your server.js location

chai.use(chaiHttp);
const expect = chai.expect;

// Mock Firebase Admin
sinon.stub(admin, 'initializeApp');
sinon.stub(admin, 'auth').get(() => firebaseAdminMock.auth());

describe('User API Endpoints', () => {
  beforeEach(() => {
    // Reset the mock before each test if needed
    firebaseAdminMock.auth().reset();
  });

  describe('POST /api/v1/users/register', () => {
    it('should register a new user', (done) => {
      const userData = { email: 'testuser@example.com', password: 'password123', username: 'testuser' };

      // Mock user creation response
      firebaseAdminMock.auth().createUser.resolves({
        uid: '123456',
        email: userData.email,
      });

      chai.request(app)
        .post('/api/v1/users/register')
        .send(userData)
        .end((err, res) => {
          expect(res).to.have.status(201);
          expect(res.body).to.have.property('userId');
          expect(res.body.email).to.equal(userData.email);
          done();
        });
    });
  });
});
