import { useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import styles from "../Components/Detail.module.css";
import style from "../Components/Review.module.css";
import axios from "axios";
import styl from "../Components/Upload.module.css";
import userImage from "../assets/user.png";
import Diamond from "../artifacts/steeloDiamond.json";
import { ethers } from "ethers";
import {diamondAddress} from "../utils/constants";





function Creator (  { items, user, setlogin, setSuccess, search, setSearch, setSelectedAbout, setSelectedService, selectedAbout, selectedService, email, token, role }: Props  ) {
	const { id } = useParams();
	console.log("id :", id);
	const navigate = useNavigate();
	const item = "";
	const [name, setName] = useState('');
	  const [image, setImage] = useState(null);
	  const [imagePreview, setImagePreview] = useState(null);
	  const [creatorData, setCreatorData] = useState("");
	const apiClient = "";




	useEffect(() => {
		
        if (!token || !email || !role) {
		    navigate("/");
	          }
	if (role != "creator") {
		navigate("/");
	}

	}, [email, token, role]);





	useEffect(() => {
		      const fetchCreatorData = async () => {
			            try {
					            const response = await axios.get(`http://localhost:9000/auth/${id}`, {
							              headers: {
									                  'Content-Type': 'application/json',
									                  Authorization: `Bearer ${token}`,
									                },
							            });

					            console.log('Creator fetched successfully');
					            console.log(response.data);
						    setCreatorData(response.data);
					          } catch (error) {
							          console.error('Network error:', error);
							        }
			          };

		      fetchCreatorData();
		    }, []);

	const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
	      const file = e.target.files?.[0];

	      if (file) {
		            setImage(file);

		            const reader = new FileReader();
		            reader.onload = () => {
				            setImagePreview(reader.result);
				          };
		            reader.readAsDataURL(file);
		          } else {
				        setImage(null);
				        setImagePreview(null);
				      }
	    };








	function ProfileUpdater(formData2: any) {
			console.log(formData2);
				 axios.put(`http://localhost:9000/creator/profile/${id}` ,
					 		formData2,
					                 {
							headers: {
							        'Content-Type': 'multipart/form-data',
							        Authorization: `Bearer ${token}`,
							 },
			                                })
					   .then(res =>  {
						   	console.log("successfully update", res.data);
//						   	window.location.reload();
						   					   			})
		                        .catch(err =>{
							console.log(err.message)
						});
				
			}

  const handleUpdate = (e: React.FormEvent) => {
	      e.preventDefault();
	      if (email && token) {
		const formData = new FormData();
			            formData.append('name', name != '' ? name: creatorData.name);
				    formData.append('photo', image != null ? image:  creatorData.profile);
	        
		            console.log(image);
		            ProfileUpdater(formData);
		     	    } else {
				console.log("no email and token found");
			  }
	    };




		async function createSteez() {
			if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
			const signerAddress = await signer.getAddress();
				await contract.createSteez();
			}
		}

		async function initializePreOrder( profileId) {
			if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
			const signerAddress = await signer.getAddress();
				await contract.initializePreOrder( profileId );
			}
		}















	return (
 <>
		    <link href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100;400&family=Aguafina+Script&family=Amatic+SC&family=Barrio&family=Bellota:wght@300&family=Black+Ops+One&family=Caveat&family=Chakra+Petch:ital,wght@1,300&family=Cinzel&family=Cookie&family=Croissant+One&family=Dancing+Script&family=Faster+One&family=Fuggles&family=Gugi&family=Hammersmith+One&family=Homemade+Apple&family=Itim&family=Lilita+One&family=Montserrat+Alternates:wght@100&family=Nothing+You+Could+Do&family=Orbitron&family=Playball&family=Rajdhani&family=Satisfy&family=Sedgwick+Ave+Display&family=Shadows+Into+Light&family=Space+Mono&family=Tilt+Prism&family=Yellowtail&display=swap" rel="stylesheet" />

			<img src={creatorData.profile ? creatorData.profile : userImage} alt="Image Preview" className={styl.previewImage} />

			<div className={styles.productdetail}>
		      
		      {email && token ? (
			              <>
			      	<div className={styl.uploadbody}>
			            <h1 className={styl.uploadtitle}>Update Profile</h1>
			      	<form className="mb-3" onSubmit={handleUpdate}>
			            <label className={styl.labeltitle}>Profile Name</label>
			            <input
			              className="form-control"
			              type="text"
			              value={name}
			              onChange={(e) => setName(e.target.value)}
			              placeholder={creatorData.name ? creatorData.name : "please insert name"}
			            />
			            <label className={styl.labeltitle}>Profile Image</label>
			            <input
			              className="form-control"
			              type="file"
			              accept="image/*"
			              onChange={handleImageChange}
			              placeholder="Put Image"
			            />
			            {imagePreview && <img src={imagePreview} alt="Image Preview" className={styl.previewImage} />}
			           
			            <button className="btn btn-primary" type="submit">
			              Update Profile
			            </button>
			          </form>
			      	</div>
			              </>
			            ) : null}
		      		 



				<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
				<div id='content' className='mt-3'>
				<button onClick={createSteez}  className='btn btn-primary btn-lg btn-block'>
				 		Create Steez
				</button>
				</div>
				<div id='content' className='mt-3'>
					Executive Page
				<button onClick={() => initializePreOrder( id )}  className='btn btn-primary btn-lg btn-block'>
					 	Initiate PreOrder
					</button>
				</div>
				</main>
		    </div>
		  </>
	)
}
export default Creator;
