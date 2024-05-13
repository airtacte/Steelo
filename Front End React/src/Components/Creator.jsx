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
//	console.log("id :", id);
	const navigate = useNavigate();
	const item = "";
	const [name, setName] = useState('');
	const [image, setImage] = useState(null);
	const [imagePreview, setImagePreview] = useState(null);
	const [creatorData, setCreatorData] = useState([]);
	const apiClient = "";

	const [contentName, setContentName] = useState("");
	const [contentDescription, setContentDescription] = useState("");
	const [video, setVideo] = useState(null);
  	const [videoPreview, setVideoPreview] = useState(null);
	const [thumbnail, setThumbnail] = useState(null);
	const [thumbnailPreview, setThumbnailPreview] = useState(null);
	const [creatorContentData, setCreatorContentData] = useState([]);
	const [isExclusive, setIsExclusive] = useState(false);
	const [creatorContentBlockchain, setCreatorContentBlockchain] = useState([]);
	const [steezTransaction, setSteezTransaction] = useState(0);


//	console.log(creatorContentBlockchain);


	useEffect(() => {
		
        if (!token || !email || !role) {
		    navigate("/");
	          }
	if (role != "creator") {
		navigate("/");
	}

	}, [email, token, role]);


	useEffect(() => {
	    let isMounted = true; // Flag to track mount status
	
	    const getAllCreatorContentsBlockchain = async (creatorId) => {
	        if (typeof window.ethereum !== "undefined") {
	       	     const provider = new ethers.providers.Web3Provider(window.ethereum);
	            const signer = provider.getSigner();
	            const contract = new ethers.Contract(
	                diamondAddress,
	                Diamond.abi,
	                signer
	       	     );
	            try {
	       	         const creatorsData = await contract.getAllCreatorContents(creatorId);
	                if (isMounted) {
	                    setCreatorContentBlockchain(creatorsData);
	                }
		            } catch (error) {
		                console.error("Failed to fetch blockchain data:", error);
		            }
		        }
	    };

    	getAllCreatorContentsBlockchain(id);
	returnSteezTransaction( id );

    return () => {
        isMounted = false; // Set the flag to false when the component unmounts
    }
}, [id]);




	useEffect(() => {
  	let isMounted = true;

	  const fetchCreatorData = async () => {
		    try {
		      const response = await axios.get(`http://localhost:9000/auth/${id}`, {
		        headers: {
		          'Content-Type': 'application/json',
		          Authorization: `Bearer ${token}`,
		        },
		      });
//		      console.log('Creator fetched successfully');
//		      console.log(response.data);
		      if (isMounted) {
		        setCreatorData(response.data);
		      }
		    } catch (error) {
		      console.error('Network error:', error);
		    }
		  };

		const fetchCreatorContentData = async () => {
		    try {
		      const response = await axios.get(`http://localhost:9000/creator/video/one?creatorId=${id}`, {
		        headers: {
		          'Content-Type': 'application/json',
		          Authorization: `Bearer ${token}`,
		        },
		      });
//		      console.log('Creator Content fetched successfully');
//		      console.log(response.data.videos);
		      if (isMounted) {
		        setCreatorContentData(response.data.videos);
		      }
		    } catch (error) {
		      console.error('Network error:', error);
		    }
		  };

  		fetchCreatorData();
  		fetchCreatorContentData();

	  return () => {
	    isMounted = false;  // set flag to false when component unmounts
	  }
	}, [id, token]);

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

	const handleThumbnailChange = (e: React.ChangeEvent<HTMLInputElement>) => {
	      const file = e.target.files?.[0];

	      if (file) {
		            setThumbnail(file);

		            const reader = new FileReader();
		            reader.onload = () => {
				            setThumbnailPreview(reader.result);
				          };
		            reader.readAsDataURL(file);
		          } else {
				        setThumbnail(null);
				        setThumbnailPreview(null);
				      }
	    };


	const handleVideoChange = (e) => {
    		const file = e.target.files[0];
    		if (file) {
      			setVideo(file);
      			const reader = new FileReader();
      		reader.onload = () => {
        		setVideoPreview(reader.result);
      		};
      		reader.readAsDataURL(file);
    		} else {
      		setVideo(null);
      		setVideoPreview(null);
    		}
  	};









	function ProfileUpdater(formData2: any) {
//			console.log(formData2);
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
						   	window.location.reload();
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
	        
//		            console.log(image);
		            ProfileUpdater(formData);
		     	    } else {
				console.log("no email and token found");
			  }
	    };



	async function handleDeleteContent( contentId ) {
		
			    try {
				await deleteContent(contentId);
				await axios.delete(`http://localhost:9000/creator/video/${contentId}`,
					{
						headers: {
					        'Content-Type': 'multipart/form-data',
					        Authorization: `Bearer ${token}`,
						 },
                        			 });
						console.log("content deleted succesfully");
				} catch (rollbackError) {
					console.error("delte failed:", rollbackError);
       				}	
	}
	 
           


	async function ContentUploader(formData2: any) {
//			console.log(formData2);
				  await axios.post(`http://localhost:9000/creator/video` ,
					 		formData2,
					                 {
							headers: {
							        'Content-Type': 'multipart/form-data',
							        Authorization: `Bearer ${token}`,
							 },
			                                })
					   .then(async res =>  {
						   	console.log("successfully uploaded", res.data.videoId); 
						   	 
						        try {
								await createContent(res.data.videoId, isExclusive);
							} catch (error) {
								try {
										await axios.delete(`http://localhost:9000/creator/video/${res.data.videoId}`,
									{
									headers: {
									        'Content-Type': 'multipart/form-data',
									        Authorization: `Bearer ${token}`,
									 },
			                               			 });
									console.log("content deleted because account is not recognized in the blockchain");
								} catch (rollbackError) {
            								console.error("Rollback failed:", rollbackError);
        							}								
								throw error;
							}
						   	window.location.reload();
						   					   			})
		                        .catch(err =>{
							console.log(err.message)
						});
				
			}

              const handleUpload = (e: React.FormEvent) => {
	      		e.preventDefault();
	      		if (email && token) {
			const formData = new FormData();
				            formData.append('name', contentName != '' ? contentName: "content");
				    	    formData.append('description', contentDescription != null ? contentDescription: "");
				    	    formData.append('creatorId', id);
				    	    formData.append('thumbnail', thumbnail != null ? thumbnail:  creatorData.profile);
				            formData.append('video', video);
		        
//			            console.log(image);
			            ContentUploader(formData);
			     	    } else {
					console.log("no email and token found");
				  }
		    };

				    


		async function deleteContent( videoId ) {
//			console.log(videoId);
			if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
			const signerAddress = await signer.getAddress();
				await contract.deleteContent(videoId );
			}
		}


		async function createContent( videoId, exclusivity) {
			if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
			const signerAddress = await signer.getAddress();
				await contract.createContent(videoId, exclusivity);
			}
		}



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

		async function returnSteezTransaction( profileId) {
			if (typeof window.ethereum !== "undefined") {
      			const provider = new ethers.providers.Web3Provider(window.ethereum);
      			const signer = provider.getSigner();
      			const contract = new ethers.Contract(
        			diamondAddress,
        			Diamond.abi,
        			signer
      			);
			const signerAddress = await signer.getAddress();
				const transaction = await contract.returnSteezTransaction( profileId );
				setSteezTransaction(parseFloat(transaction));
			}
		}


	const handleVideoPlay = (index) => {
    		setActiveVideo(index);
    		const videoElement = document.getElementById(`video${index}`);
    		videoElement.play();
    		videoElement.onpause = () => setActiveVideo(null); // Add onpause event handler
	  };
		

	const [activeVideo, setActiveVideo] = useState(null);









	return (
 <>
		    <link href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100;400&family=Aguafina+Script&family=Amatic+SC&family=Barrio&family=Bellota:wght@300&family=Black+Ops+One&family=Caveat&family=Chakra+Petch:ital,wght@1,300&family=Cinzel&family=Cookie&family=Croissant+One&family=Dancing+Script&family=Faster+One&family=Fuggles&family=Gugi&family=Hammersmith+One&family=Homemade+Apple&family=Itim&family=Lilita+One&family=Montserrat+Alternates:wght@100&family=Nothing+You+Could+Do&family=Orbitron&family=Playball&family=Rajdhani&family=Satisfy&family=Sedgwick+Ave+Display&family=Shadows+Into+Light&family=Space+Mono&family=Tilt+Prism&family=Yellowtail&display=swap" rel="stylesheet" />

			<img src={creatorData.profile ? creatorData.profile : userImage} alt="Image Preview" style={{ borderRadius: '50%'}} className={styl.previewImage} />

			<div className={styles.productdetail}>
		      
		      {email && token ? (
			              <>


			      <table className='table text-muted text-center'>
					<thead>
					<tr style={{ color: 'white' }}>
						<th scope='col'>Total Steez Transaction</th>
					</tr>
					</thead>
					<tbody>
					<tr style={{ color: 'white' }}>
						<td>{steezTransaction}</td>
					</tr>
					</tbody>
				</table>


			      	<div className={styl.uploadbody} style={{marginTop: '100px'}}>
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
			            {imagePreview && <img src={imagePreview} alt="Image Preview" style={{marginTop: '30px', width: '300px' }}className="img-thumbnail" />}
			           
			            <button className="btn btn-primary" style={{ marginLeft: '30px' }} type="submit">
			              Update Profile
			            </button>
			          </form>
			      	</div>











				<div className={styl.uploadbody}>
			            <h1 className={styl.uploadtitle}>Upload Content</h1>
			      	<form className="mb-3" onSubmit={handleUpload}>
			            <label className={styl.labeltitle}>Content Name</label>
			            <input
			              className="form-control"
			              type="text"
			              value={contentName}
			              onChange={(e) => setContentName(e.target.value)}
			              placeholder={"please insert content name"}
			              required
			            />
			            <label className={styl.labeltitle}>Thumbnail</label>
			            <input
			              className="form-control"
			              type="file"
			              accept="image/*"
			              onChange={handleThumbnailChange}
			              placeholder="Put Thumbnail"
			              required
			            />
			            {thumbnailPreview && <img src={thumbnailPreview} alt="Image Preview" style={{marginTop: '30px', width: '300px' }}className="img-thumbnail" />}
			            <label className={styl.labeltitle}>Content</label>
			           <input
			                className="form-control"
          				type="file"
          				accept="video/mp4,video/x-m4v,video/*,.mkv"
			      		onChange={handleVideoChange}
			                placeholder="Put Content"
			                required
        			/>
        			{videoPreview && (
          			<video width="320" height="240" controls>
            				<source src={videoPreview} type="video/mp4" />
            				Your browser does not support the video tag.
          			</video>
        			)}
				   <label className={styl.labeltitle}>Content Description</label>
			            <textarea
					className="form-control form-control-lg"
  					value={contentDescription}
  					onChange={(e) => setContentDescription(e.target.value)}
  					placeholder="please insert content description"
  					rows="4"
  					style={{ height: 'auto' }}
					></textarea>

			            <label className={styl.labeltitle}>Exclusivity</label>
					<select
					    className="form-control"
					    value={isExclusive}
					    onChange={(e) => setIsExclusive(e.target.value === 'true')}
					    required
					  >
					    <option value="false">Not Exclusive</option>
					    <option value="true">Exclusive</option>
					  </select>
			      	     
			           
			            <button className="btn btn-primary" style={{ marginLeft: '30px' }} type="submit">
			              Upload Content
			            </button>
			          </form>
			      	</div>
			      
			              </>
			            ) : null}
		      		


			<main role="main" className="col-lg-12 mx-auto" style={{ maxWidth: '600px', minHeight: '100vh' }}>
			    <div id="content" className="mt-3">
			        {creatorContentData?.map((content, index) => (
			            <div key={index} className="list-group-item list-group-item-action bg-dark text-white mb-2">
			                    <div className="d-flex justify-content-between align-items-center">
 			                       <div className="w-100">
			                            <h5 className="mb-1">Content Name :{content?.name}</h5>
						    
							<video 
				                  id={`video${index}`} 
				                  className="img-fluid" 
			                  controls 
	                  style={{ display: activeVideo === index ? 'block' : 'none', width: '100%' }}
	                >
	                  <source src={content?.videoUrl} type="video/mp4" />
	                  Your browser does not support the video tag.
	                </video>
	                {content?.thumbnailUrl && activeVideo !== index && (
	                  <img 
	       	             src={content?.thumbnailUrl} 
	       	             alt="Image Preview" 
	       	             className="img-fluid w-100" 
	                    style={{ cursor: 'pointer' }} 
		       	             onClick={() => handleVideoPlay(index)}
		                  />
		                )}
			                        </div>
			                    </div>
		                    <div>Comments : {content?.comments}</div>
		                    <div>description : {content?.description}</div>
		                    <div>likes : {content?.likes}</div>
		                    <div>shares : {content?.shares}</div>
				    <div>upload time :{new Date(creatorContentBlockchain?.find(element => element.contentId === content?.id)?.uploadTimestamp.toNumber() * 1000).toString()}</div>
				    <div>exclusivity :{creatorContentBlockchain?.find(element => element.contentId === content?.id)?.exclusivity ? "exclusive" : "not exclusive"}</div>
					<button onClick={() => handleDeleteContent(content?.id)}className="btn btn-danger">Delete content</button>
			            </div>
			        ))}
			    </div>
			</main>
				



				<main role='main' className='col-lg-12 ml-auto mr-auto' style={{ maxWidth: '600px', minHeight: '100vm' }}>
				<div id='content' className='mt-3'>
				<button onClick={createSteez}  className='btn btn-primary btn-lg btn-block'>
				 		Create Steez
				</button>
				</div>
				<div id='content' className='mt-3'>
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
