import React, { useState, useEffect } from 'react';
import { fetchMosaicContent, fetchNextRelevantCreator, manageCollaborators } from './services/MosaicService';
import { SteeloTokenService } from './services/TokenService';

const MosaicMain = () => {
    const [currentCreatorContent, setCurrentCreatorContent] = useState([]);
    const [nextRelevantCreatorContent, setNextRelevantCreatorContent] = useState([]);
    const [collaborators, setCollaborators] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Fetch the current creator's content
        fetchMosaicContent().then(data => {
            setCurrentCreatorContent(data);
        });

        // Fetch the next most relevant creator's content
        fetchNextRelevantCreator().then(data => {
            setNextRelevantCreatorContent(data);
        });

        // Fetch the collaborators for this mosaic
        manageCollaborators().then(data => {
            setCollaborators(data);
            setLoading(false);
        });
    }, []);

    // Scroll event listener
    const handleScroll = (event) => {
        // Implement the logic to load more content or switch creators based on the scroll direction
        // Here, you can detect vertical or horizontal scrolling and fetch more data accordingly.
    };

    if (loading) {
        return <div>Loading...</div>;
    }

    return (
        <div className="mosaic-main" onScroll={handleScroll}>
            <h1>Mosaic Dashboard</h1>
            
            <div className="mosaic-content-vertical">
                {currentCreatorContent.map((content, index) => (
                    <div key={index} className="mosaic-piece">
                        {content}
                    </div>
                ))}
            </div>

            <div className="mosaic-content-horizontal">
                {nextRelevantCreatorContent.map((content, index) => (
                    <div key={index} className="mosaic-piece">
                        {content}
                    </div>
                ))}
            </div>

            <div className="mosaic-collaborators">
                <h2>Collaborators</h2>
                <ul>
                    {collaborators.map((collab, index) => (
                        <li key={index}>{collab.name}</li>
                    ))}
                </ul>
            </div>
        </div>
    );
}

export default MosaicMain;
