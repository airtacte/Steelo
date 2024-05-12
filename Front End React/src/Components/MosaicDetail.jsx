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





function MosaicDetail (  { items, user, setlogin, setSuccess, search, setSearch, setSelectedAbout, setSelectedService, selectedAbout, selectedService, email, token, role , userId}: Props  ) {
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
	const [investors, setInvestors] = useState([]);
	const [isLoading, setIsLoading] = useState(true);



//	console.log(creatorContentBlockchain);
//	console.log("invesotrs :", investors);
	console.log(userId);




	useEffect(() => {
        	getAllContentsBlockchain();
		getAllInvestors( id );
    }, [id]);

	const checkLoading = () => {
   		 if (creatorContentBlockchain.length > 0 && investors.length > 0) {
   		   setIsLoading(false);
    }
  };

	async function getAllContentsBlockchain() {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			const creatorsData = await contract.getAllContents();
			setCreatorContentBlockchain(creatorsData);
			}
		}
	async function getAllInvestors( creatorId) {
		if (typeof window.ethereum !== "undefined") {
		const provider = new ethers.providers.Web3Provider(window.ethereum);
      		const signer = provider.getSigner();
      		const contract = new ethers.Contract(
        		diamondAddress,
        		Diamond.abi,
        		signer
      		);
		const signerAddress = await signer.getAddress();
			const investorsData = await contract.getAllInvestors( creatorId );
			setInvestors( investorsData );
			}
		}





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
		      console.log('Creator Content fetched successfully');
		      console.log(response.data.videos);
		      if (isMounted) {
		        setCreatorContentData(response.data.videos);
		      }
		    } catch (error) {
		      console.error('Network error:', error);
		    }
		  };

  		fetchCreatorData();
  		fetchCreatorContentData();
		checkLoading();

	  return () => {
	    isMounted = false;  // set flag to false when component unmounts
	  }
	}, [token, investors]);

	useEffect(() => {
		
        	if (!localStorage.getItem("token")) {
		    navigate("/");
	          }

	}, [email, token, role]);

	

	const [activeVideo, setActiveVideo] = useState(null);




	const handleVideoPlay = (index) => {
    		setActiveVideo(index);
    		const videoElement = document.getElementById(`video${index}`);
    		videoElement.play();
    		videoElement.onpause = () => setActiveVideo(null); // Add onpause event handler
  	};






	if (isLoading) {
    	return (
	        <div className="d-flex justify-content-center align-items-center vh-100" style={{ marginLeft: '50%'}}>
            <div className="spinner-border text-primary" style={{ width: '3rem', height: '3rem' }} role="status">
                <span className="visually-hidden">Loading...</span>
            </div>
        </div>
	    );
	}



	



	return (
 <>
		    <link href="https://fonts.googleapis.com/css2?family=Advent+Pro:wght@100;400&family=Aguafina+Script&family=Amatic+SC&family=Barrio&family=Bellota:wght@300&family=Black+Ops+One&family=Caveat&family=Chakra+Petch:ital,wght@1,300&family=Cinzel&family=Cookie&family=Croissant+One&family=Dancing+Script&family=Faster+One&family=Fuggles&family=Gugi&family=Hammersmith+One&family=Homemade+Apple&family=Itim&family=Lilita+One&family=Montserrat+Alternates:wght@100&family=Nothing+You+Could+Do&family=Orbitron&family=Playball&family=Rajdhani&family=Satisfy&family=Sedgwick+Ave+Display&family=Shadows+Into+Light&family=Space+Mono&family=Tilt+Prism&family=Yellowtail&display=swap" rel="stylesheet" />


		


					      		


	
		<main role="main" className="col-lg-12 mx-auto" style={{ maxWidth: '600px', minHeight: '100vh' }}>
        <div id="content" className="mt-3">
          {creatorContentData?.map((content, index) => {
            const isInvestor = investors.some(element => element.investorId === userId);
            const isContentExclusive = creatorContentBlockchain.some(element => element.contentId === content?.id && element.exclusivity);
            const shouldDisplay = !isContentExclusive || (isContentExclusive && isInvestor);

            return shouldDisplay && (
              <div key={index} className="list-group-item list-group-item-action bg-dark text-white mb-2">
                <div className="d-flex justify-content-between align-items-center">
                  <div>
                    <h5 className="mb-1">Content Name: {content?.name}</h5>
                    <video id={`video${index}`} className="img-fluid" controls style={{ display: activeVideo === index ? 'block' : 'none' }}>
                      <source src={content?.videoUrl} type="video/mp4" />
                      Your browser does not support the video tag.
                    </video>
                    {content?.thumbnailUrl && activeVideo !== index && (
                      <img src={content?.thumbnailUrl} alt="Image Preview" className="img-fluid top-0 start-0 w-100" style={{ cursor: 'pointer' }} onClick={() => handleVideoPlay(index)} />
                    )}
                  </div>
                </div>
                <div>Comments: {content?.comments}</div>
                <div>Description: {content?.description}</div>
                <div>Likes: {content?.likes}</div>
                <div>Shares: {content?.shares}</div>
                <div>Upload time: {new Date(creatorContentBlockchain.find(element => element.contentId === content?.id)?.uploadTimestamp.toNumber() * 1000).toString()}</div>
                <div>Exclusivity: {isContentExclusive ? "Exclusive" : "Not Exclusive"}</div>
              </div>
            );
          })}
        </div>
      </main>		


		  </>
	)
}
export default MosaicDetail;
